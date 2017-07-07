"""
Challenge deployment and problem types.
"""

from abc import ABCMeta, abstractmethod, abstractproperty
from hashlib import md5
from hacksport.operations import execute
from hacksport.deploy import give_port

from shell_manager.util import EXTRA_ROOT
from shutil import copy2

from random import Random
import os
from os.path import join

class File(object):
    """
    Wraps files with default permissions
    """

    def __init__(self, path, permissions=0o664, user=None, group=None):
        self.path = path
        self.permissions = permissions
        self.user = user
        self.group = group

    def __repr__(self):
        return "{}({},{})".format(self.__class__.__name__, repr(self.path), oct(self.permissions))

    def to_dict(self):
        return {
            "path": self.path,
            "permissions": self.permissions,
            "user": self.user,
            "group": self.group
        }

class PreTemplatedFile(File):
    """
    Wrapper for files that should be served pre-templated.
    """

    def __init__(self, path, permissions=0o664):
        super().__init__(path, permissions=permissions)

class ExecutableFile(File):
    """
    Wrapper for executable files that will make them setgid and owned
    by the problem's group.
    """

    def __init__(self, path, permissions=0o2755):
        super().__init__(path, permissions=permissions)

class ProtectedFile(File):
    """
    Wrapper for protected files, i.e. files that can only be read after
    escalating privileges. These will be owned by the problem's group.
    """

    def __init__(self, path, permissions=0o0440):
        super().__init__(path, permissions=permissions)

def files_from_directory(directory, recurse=True, permissions=0o664):
    """
    Returns a list of File objects for every file in a directory. Can recurse optionally.

    Args:
        directory: The directory to add files from
        recurse: Whether or not to recursively add files. Defaults to true
        permissions: The default permissions for the files. Defaults to 0o664.
    """

    result = []

    for root, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            result.append(File(join(root, filename), permissions))
        if not recurse:
            break

    return result


class Challenge(metaclass=ABCMeta):
    """
    The most hands off, low level approach to creating challenges.
    Requires manual setup and generation.
    """

    files = []
    dont_template = []

    def generate_flag(self, random):
        """
        Default generation of flags.

        Args:
            random: seeded random module.
        """

        token = str(random.randint(1, 1e24))
        hash_token = "flag{" + md5(token.encode("utf-8")).hexdigest() + "}"

        return hash_token

    def initialize(self):
        """
        Initial setup function that runs before any other.
        """

        pass

    @abstractmethod
    def setup(self):
        """
        Main setup method for the challenge.
        This is implemented by many of the more specific problem types.
        """

        pass

    def service(self):
        """
        No-op service file values.
        """

        return {
            "Type": "oneshot",
            "ExecStart": "/bin/bash -c 'echo started'"
        }


class Compiled(Challenge):
    """
    Sensible behavior for compiled challenges.
    """

    compiler = "gcc"
    compiler_flags = []
    compiler_sources = []

    makefile = None

    program_name = None

    compiled_files = []

    def setup(self):
        """ No-op implementation for Challenge. """
        pass

    def compiler_setup(self):
        """
        Setup function for compiled challenges
        """

        if self.program_name is None:
            raise Exception("Must specify program_name for compiled challenge.")

        if self.makefile is not None:
            execute(["make", "-f", self.makefile])
        elif len(self.compiler_sources) > 0:
            compile_cmd = [self.compiler] + self.compiler_flags + self.compiler_sources
            compile_cmd += ["-o", self.program_name]
            execute(compile_cmd)

        if not isinstance(self, Remote):
            # only add the setgid executable if Remote is not handling it
            self.compiled_files = [ExecutableFile(self.program_name)]


class Service(Challenge):
    """
    Base class for challenges that are remote services.
    """

    service_files = []

    def setup(self):
        """
        No-op implementation of setup
        """

        pass

    def service_setup(self):
        if self.start_cmd is None:
            raise Exception("Must specify start_cmd for services.")

    @property
    def port(self):
        """
        Provides port on-demand with caching
        """
        if not hasattr(self, '_port'):
            self._port = give_port()
        return self._port


    def service(self):
        return {"Type":"simple",
                "ExecStart":"/bin/bash -c \"{}\"".format(self.start_cmd)
               }

class Remote(Service):
    """
    Base behavior for remote challenges that use stdin/stdout.
    """

    remove_aslr = False

    def remote_setup(self):
        """
        Setup function for remote challenges
        """

        if self.program_name is None:
            raise Exception("Must specify program_name for remote challenge.")

        if self.remove_aslr:
            # do not setgid if being wrapped
            self.service_files = [File(self.program_name, permissions=0o755)]

            self.program_name = self.make_no_aslr_wrapper(join(self.directory, self.program_name),
                                                          output="{}_no_aslr".format(self.program_name))
        else:
            self.service_files = [ExecutableFile(self.program_name)]

        # test crnl option !!! testing
        self.start_cmd = "socat tcp-listen:{},fork,reuseaddr,crnl EXEC:'{}',pty,rawer".format(self.port, join(self.directory, self.program_name))

    def make_no_aslr_wrapper(self, exec_path, output="no_aslr_wrapper"):
        """
        Compiles a setgid wrapper to remove aslr.
        Returns the name of the file generated
        """

        source_path = "no_aslr_wrapper.c"
        execute(["gcc", "-o", output, "-DBINARY_PATH=\"{}\"".format(exec_path), join(EXTRA_ROOT, source_path)])
        self.files.append(ExecutableFile(output))

        return output


class FlaskApp(Service):
    """
    Class for python Flask web apps
    """

    python_version = "3"
    app = "server:app"
    num_workers = 1

    @property
    def flask_secret(self):
        """
        Provides flask_secret on-demand with caching
        """
        if not hasattr(self, '_flask_secret'):
            token = str(self.random.randint(1, 1e16))
            self._flask_secret = md5(token.encode("utf-8")).hexdigest()

        return self._flask_secret

    def flask_setup(self):
        """
        Setup for flask apps
        """

        self.app_file = "{}.py".format(self.app.split(":")[0])
        assert os.path.isfile(self.app_file), "module must exist"

        if self.python_version == "2":
            plugin_version = ""
        elif self.python_version == "3":
            plugin_version = "3"
        else:
            assert False, "Python version {} is invalid".format(python_version)

        self.service_files = [File(self.app_file)]
        self.start_cmd = "uwsgi --protocol=http --http-socket :{2} --plugin python{} -p {} -w {} --logto /dev/null".format(plugin_version, self.num_workers, self.app, self.port)

class PHPApp(Service):
    """
    Class for PHP web apps
    """

    php_root = ""
    num_workers = 1

    def php_setup(self):
        """
        Setup for php apps
        """

        web_root = join(self.directory, self.php_root)
        self.start_cmd = "uwsgi --protocol=http --http-socket :{2} --plugin php -p {1} --php-allowed-docroot {0} --force-cwd {0} --http-socket-modifier1 14 --php-index index.html --php-index index.php --static-index index.html --check-static {0} --static-skip-ext php --logto /dev/null".format(web_root, self.num_workers, self.port)

class Forensics(Challenge):
    # Files to be included in the challenge, which must
    #   be generated by Realtime
    #   or picked by Autogen
    # Typically will be a single file
    forensics_files = []

    def setup(self):
        # Although apparently if you had the files defined in forensics_files, it still worked...
        files = copy([File(f) for f in self.forensics_files])

    # We leave the generate_flag as default, but it may be necessary
    #   to overwrite it, as some challenges may need particular flag formats
    #def generate_flag(self,random):
    #   pass

class Realtime(Forensics):
    """
    We should be able to generate a file in real-time to use
    """

    def setup(self):
        pass

    def initialize(self):
        self.forensics_files = self.generate_challenge()
        if(len(self.forensics_files) < 1):
            raise Exception("Forensics challenges should provide at least 1 challenge file (files).")

    # By default, realtime forensics challenges will generate a default flag (32 character MD5)

    @abstractmethod
    # Challenge-developer-defined function to define how it will generate
    #   a forensics challenge file
    # Return a list of File objects to be included in the challenge
    def generate_challenge(self):
        raise Exception("generate_challenge function not implemented")

class Pregen(Forensics):
    """
    We should already have challenges files for us to pick among from
    """

    # There could be multiple files involved in a forensics challenge
    # So we will get a challenge by randomly picking a challenge_id

    # challenge_id clarification examples (X is an int):
    #    - File for challenge id X named outX.png & answers in files name outX
    #    - Files for challenge id X in a directory named outX & answers under X
    #         in JavaScript or other data file
    # This way you can easily randomly pick a challenge id & find the
    #   corresponding challenge files & answer
    challenge_id = ""

    def setup(self):
        pass

    def initialize(self):
        pass

    # We redefine generate_flag since the flag has already been preautogenerated
    #   by however the challenge developer decided. We take the flag from a file
    #   or wherever the challenge developer stashed the corresponding answers.
    def generate_flag(self,random):
        # First we need to pick the challenge id
        self.pick_challenge_id()

        # challenge_id must not be empty
        if(self.challenge_id == ""):
            raise Exception("Must implement pick_challenge_id to pick a challenge id and store in self.challenge_id.")

        # Get the corresponding answer to the chosen challenge id
        ans = self.get_ans()

        # ans must not be the empty string
        if((type(ans) is not str) or (ans == "")):
            raise Exception("Answer ans must be a string that's not the empty string.")

        # Get the corresponding files to the chosen challenge id
        self.forensics_files = self.get_challenge_files()

        # files must not be empty (there shouldn't be a forensics challenge)
        #   where a file isn't given
        if(len(self.forensics_files) < 1):
            raise Exception("Forensics challenges should provide at least 1 challenge file (files).")

        return ans

    @abstractmethod
    # Challenge-developer-defined function to pick a random challenge id
    def pick_challenge_id(self):
        raise Exception("pick_challenge_id function not implemented")

    @abstractmethod
    # Challenge developer-defined function to obtain answer corresponding to
    #   defined challenge id
    # Returns ans as string
    def get_ans(self):
        raise Exception("get_ans function not implemented")

    @abstractmethod
    # Challenge developer-defined function to obtain challenge files
    #   corresponding to defined challenge id
    # Return challenge files as list of Files
    def get_challenge_files(self):
        raise Exception("get_challenge_files function not implemented")