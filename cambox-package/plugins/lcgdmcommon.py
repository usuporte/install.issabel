#!/usr/bin/env python
##############################################################################
# Copyright (c) Members of the EGEE Collaboration. 2011.
# See http://www.eu-egee.org/partners/ for details on the copyright
# holders.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##############################################################################
#
# NAME :        lcgdmcommon
#
# DESCRIPTION : Common routines for LCGDM NAGIOS Plugins
#
# AUTHORS :     Alejandro.Alvarez.Ayllon@cern.ch, Alexandre.Beche@cern.ch
#
##############################################################################

import getopt
import os
import sys
import traceback
import re

from datetime import datetime
from time import localtime

PACKAGE_NAME    = "<PACKAGE_NAME>"
PACKAGE_VERSION = "<PACKAGE_VERSION>"

# Exit codes (NAGIOS compliant)
EX_OK       = 0
EX_WARNING  = 1
EX_CRITICAL = 2
EX_UNKNOWN  = 3

# Verbosity
V_MINIMAL  = 0
V_EXTENDED = 1
V_DEBUG    = 2
V_ALL      = 3

# Some module variables
verbose = V_MINIMAL

# Access to verbose
def verbosity(base):
  """
  Returns True if the current verbosity level is equal or higher than base
  """
  return verbose >= base

# Prints debug information into stderr if verbose is enabled
def debug(msg):
  """
  Prints debug information into stderr if verbose is enabled
  """
  if verbose > V_EXTENDED:
    print >>sys.stderr, msg

# Standard version printing
def version(test):
  """
  Prints the name and version of the test, plus the name and version
  of the package.

  @param test The test
  """
  print "%s v%s (%s %s)" % (test.__name__, test.__version__, PACKAGE_NAME, PACKAGE_VERSION)


# Test usage
def usage(test):
  """
  Prints the usage of the test. Automatically prints the common part,
  and appends the test specific part, if any

  @param test A test instance
  """
  print """
%s

Usage: %s [options]

\t-h, --help\tShows this help
\t-V, --version\tShows this plugin version
\t-v, --verbose\tSets verbose mode""" % (test.__doc__, sys.argv[0])

  if test.__usage__:
    print test.__usage__

  print """Send and email to dpm-users-forum@cern.ch if you have questions
regarding the use of this software. To submit patches or suggest improvements
send an email to dpm-devel@cern.ch
  """


# Reads the whole content of a file
def cat(path):
  """
  Behaves like the cat command in bash

  @param path The file to dump
  @return A list with the lines
  """
  f = open(path)
  lines = f.readlines()
  f.close()
  return lines

# Splits a string using the character comma and returns an n-tuple
# at least, and minimum
def get_tuple(string, n, as_int = False):
  """
  Splits a string into n tuples, ignoring the rest if there are more, and replicating
  if there is only one

  @param string   The string
  @param n        The number of elements
  @param as_int   If true, it will cast to int
  """
  t = string.split(",")
  if len(t) == n:
    t = tuple(t)
  elif len(t) > n:
    t = tuple(t[:n - 1])
  elif len(t) == 1:
    t = tuple(t * n)
  else:
    raise IndexError("Invalid number of values")

  if as_int:
    return tuple([int(i) for i in t])
  else:
    return t

# Returns the same value, or if it is a percentage, applies it
def real_value(value, base):
  """
  Returns int(value) if it isn't a percentage, or applies it over base

  @param value The value or percentage
  @param base  The maximum value if value is a percentage
  """
  try:
    if not value.endswith('%'):
      return int(value)
    else:
      value = float(value[:-1])
      return int((value / 100) * base)
  except ValueError:
    raise ValueError("Invalid values")

# Returns a size in bytes as an integer (accepts suffixes)
def real_bytes(value):
  """
  Returns a size in bytes as an integer (accepts suffixes)

  @param value An integer finished, optionally, with a suffix (K, M, G, T, P)
  """
  si_suffix = {"K":10**3, "M":10**6, "G":10**9, "T":10**12, "P":10**15}
  bin_suffix = {"k":2**10, "m":2**20, "g":2**30, "t":2**40, "p": 2**50}
  suffixes = dict(si_suffix.items() + bin_suffix.items())

  try:
    if value.isdigit():
      return int(value)

    suffix = value[-1]
    value = int(value[:-1])

    if suffix in suffixes.keys():
      return (value * suffixes[suffix])
    else:
      raise ValueError
  except ValueError:
    raise ValueError("Could not convert the value to a size: %s" % value)

def standard_units(size, prefered_unit = None):
  si_suffix = {"K":10**3, "M":10**6, "G":10**9, "T":10**12, "P":10**15}
  bin_suffix = {"k":2**10, "m":2**20, "g":2**30, "t":2**40, "p": 2**50}
  suffixes = dict(si_suffix.items() + bin_suffix.items())
  size = float(size) 
  if prefered_unit in suffixes.keys():
    size /= suffixes[prefered_unit]
  return size

  
# Returns the exit code if a code with more preference is not already there
def safe_exit(code, prev):
  """
  Returns the exit code if a code with more preference is not already there
  @param code The new exit code
  @param prev The previous exit code
  """

  if code > prev:
    return code
  else:
    return prev

# Reversed-block iterator
def reversed_blocks(file, bsize = 4096):
  """
  Allows to iterate a file block by block in reversed order
  """
  file.seek(0, 2)
  offset = file.tell()
  while 0 < offset:
    delta  = min(offset, bsize)
    offset -= delta
    file.seek(offset, 0)
    yield file.read(delta)

# Reversed-line iterator
def reversed_lines(file):
  """
  Allows to iterate a file line by line in reversed order without reading the whole
  file
  """
  tail = []
  for block in reversed_blocks(file):
    linelist = [[line] for line in block.splitlines()]
    linelist[-1].extend(tail)
    for line in reversed(linelist[1:]):
      yield ''.join(line)
    tail = linelist[0]
  if tail: yield ''.join(tail)

######################################################
#                                                    #
# Common functions for dpm/dpns/lfc logfile parsing  #
#                                                    #
######################################################

# return a function dictionary initializate to 0: {function-1:{operation-count:0, total-time:0}, ..., function-n:{}}
def init_functions_dictionary(functions_list):
  function_dictionary = {}
  for function in functions_list:
    function_dictionary[function] = {"operation-count":int(0),"total-time":float(0)}

  return function_dictionary

# Add the average time per function to the function dictionary
def compute_average_time_per_function(function_dictionary):
  for function_name, function_values in function_dictionary.iteritems():
    if function_dictionary[function_name]["operation-count"] != 0:
      function_dictionary[function_name]["average-time"] = float(function_dictionary[function_name]["total-time"] / function_dictionary[function_name]["operation-count"])
    else:
      function_dictionary[function_name]["average-time"] = 0

  return function_dictionary

# from a logfile formated date, return a millisecond timestamp
def get_millisecond(timestamp):
  timestamp = timestamp.split()
  day, timestamp = int(timestamp[0]), timestamp[1]
  timestamp = timestamp.split(".")
  millisecond, timestamp = int(timestamp[1]), timestamp[0].split(":")
  hour, minute, second = int(timestamp[0]), int(timestamp[1]), int(timestamp[2])

  return (1000 * ((3600 * 24 * day) + (3600 * hour) + (60 * minute) + second)) + millisecond

# convert millisecond timestamp into a second timestamp
def get_second(timestamp):
  return get_millisecond(timestamp) / 1000

# Logfile parsing function
def parse_daemon_logfile(logfile_name, request_code, functions, interval):
  pattern = re.compile("^.*/(.. ..:..:..\....).*,(.*) ..._srv_(.*): (returns|"+request_code+") (\d|-).*$")
  logfile = open(logfile_name, "r")
  buffer = {}

  function_dictionary = init_functions_dictionary(functions)
  current_timestamp = get_second(datetime.now().strftime("%d %H:%M:%S.00"))
  for line in reversed_lines(logfile):
    found = pattern.search(line)    
    if found: 
      timestamp = found.group(1)
      thread_id = found.group(2)
      function_name = found.group(3)
      return_code = found.group(4)

      # return the current dictionary if the logline timestamp is highter than the current timestamp - 'interval' minutes
      if get_second(timestamp) < (current_timestamp -(60 * interval)): 
        return function_dictionary

      # If a returns line is detected, the timestamp is put in a buffer dictionary where the key is the server thread id
      if (function_name in functions) and (return_code == "returns"):
        buffer[thread_id] = get_millisecond(timestamp)
        continue

      # If a request line is detected and the buffer dict has an elem with the same thread id, compute the average time 
      if (buffer.has_key(thread_id)) and (return_code == request_code):
        time_ellapsed =  buffer[thread_id] - get_millisecond(timestamp)

        function_dictionary[function_name]["operation-count"] += 1
        function_dictionary[function_name]["total-time"] += float(time_ellapsed) / 1000
        
        del buffer[thread_id]
  
  logfile.close()
  return function_dictionary


# Common code for probes that need user certificate/key or proxy
class X509:
  arguments = {"K": "user-key=",
               "T": "user-cert=",
               "X": "user-proxy="}

  help = """
\t--user-key   User private key.
\t--user-cert  User certificate.
\t--user-proxy User proxy.
"""

  @classmethod
  def setEnv(cls, opt):
    """
    Set the X509_* environment variables form the options
    @param opt A dictionary
    """
    for (arg, env) in {"user-key": "X509_USER_KEY", "user-cert": "X509_USER_CERT", "user-proxy": "X509_USER_PROXY"}.iteritems():
      if arg in opt:
        os.environ[env] = opt[arg]
        debug("%s overriden with %s" % (env, opt[arg]))


# Wrapper
def run(test):
  """
  Executes the test instance, wrapping it in case something nasty
  happens

  @param test A _class_ that implements the proper methods
  """
  global verbose

  try:
    long_opts = ["help", "version", "verbose", "vv", "vvv"]
    long_opts.extend(test.__additional_opts__.values())
    opts, args = getopt.getopt(sys.argv[1:], "hVv" + ''.join(test.__additional_opts__.keys()), long_opts)

    # Parameters
    extra = dict()
    for opt, arg in opts:
      if opt in ("-h", "--help"):
        usage(test)
        sys.exit(EX_OK)
      elif opt in ("-V", "--version"):
        version(test)
        sys.exit(EX_OK)
      elif opt in ("-v", "--verbose"):
        verbose += 1

      # It is a test parameter (--warning, --critical or specific)
      if opt.startswith("--"):
        name = opt[2:]
      else:
        name = opt[1:]  
 
      if len(name) == 1:
        if name in test.__additional_opts__:
          name = test.__additional_opts__[name]
        elif name + ':' in test.__additional_opts__:
          name = test.__additional_opts__[name + ':']

      if name.endswith('='):
        name = name[:-1]

      extra[name] = arg
       
    # Initiate and call
    status = None
    try:
      instance = test(extra, args)
    except KeyError, e:
      print "UNKNOWN - Parameter %s is needed" % str(e)
      sys.exit(EX_UNKNOWN)
    except Exception, e:
      print "UNKNOWN - %s" % str(e)
      if verbose:
        traceback.print_exc()
      sys.exit(EX_UNKNOWN)

    (status, output, performance) = instance.main()

    # If available, print test prefix
    if '__nagios_id__' in dir(instance):
      print instance.__nagios_id__,

    # Print output with right prefix
    if status == EX_OK:
      print "OK -",
    elif status == EX_WARNING:
      print "WARNING -",
    elif status == EX_CRITICAL:
      print "CRITICAL -",
    else:
      print "UNKNOWN -",

    print output,

    if performance:
      print "|", performance
    else:
      print

    # Return status
    sys.exit(status)
  except SystemExit:
    raise
  except Exception, e:
    print "CRITICAL - %s" % str(e)
    if verbose:
      traceback.print_exc(file = sys.stderr)
    sys.exit(EX_CRITICAL)
