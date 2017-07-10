#!/usr/bin/python2
from Crypto.Cipher import AES
import os, sys

flag = open("flag", "r").read().strip()
key = open("key", "r").read().strip()

welcome = """
{{welcome_message}}
"""

def encrypt():
  cipher = AES.new(key.decode('hex'), AES.MODE_ECB)
  return cipher.encrypt(flag).encode("hex")

# flush output immediately
sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
print welcome
print "KEY: " + key
print "MESSAGE: " + encrypt()
