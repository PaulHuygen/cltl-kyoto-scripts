#!/usr/bin/env python
from __future__ import print_function
import logging
import sys
import argparse
import os

MAX_NAME_LEN = 1024
helptext = { 'nuwebfile': 'The file to be processed.'
           , 'r': 'Options for hyperref.'
           , 'v': 'Be verbose.'
           , 't': 'Don\'t generate tex.'
           , 'o': 'Don\'t generate output.'
           , 'd': 'List dangling id. references in indexes.'
           , 'c': 'Overwrite all output files.'
           , 'n': 'Number scraps sequentially.'
           , 's': 'Don\'t print list of scraps at end of each scrap.'
           , 'x': 'Include cross-reference numbers in scrap comments.'
           , 'p': 'Prepend [path] to the names of the output files.'
           , 'y': 'Options for the hyperref package.'
           , 'r': 'Generate hyperlinks.'
           }
nw_char = "@"
source_name = None
tex_name = None
aux_name = None
rootdir = None

def true_or_false(b):
    if b:
        return "T"
    else:
        return "F"
def list_options( infil, tex, aux, root):
  global nuwebflags
  print("{}: {}".format("nuwebfile", args.nuwebfile))
  if args.hyperopts:
     print("{}: {}".format("hyperopts", args.hyperopts))
  else:
     print("{}: {}".format("hyperopts", "None"))
  if args.path:
     print("{}: {}".format("path", args.path))
  else:
     print("{}: {}".format("path", "None"))
  print("{}: {}".format("verbose", true_or_false(args.verbose)))
  
  print("{}: {}".format("notex", true_or_false(args.notex)))
  
  print("{}: {}".format("no_out", true_or_false(args.no_out)))
  
  print("{}: {}".format("no_dangling", true_or_false(args.no_dangling)))
  
  print("{}: {}".format("no_compare", true_or_false(args.no_compare)))
  
  print("{}: {}".format("seqnumber", true_or_false(args.seqnumber)))
  
  print("{}: {}".format("no_scraplist", true_or_false(args.no_scraplist)))
  
  print("{}: {}".format("xref", true_or_false(args.xref)))
  
  print("Filenames:")
  print("{}: {}".format("inputfile", infil))
  print("{}: {}".format("texfile", tex))
  print("{}: {}".format("auxfile", aux))
  print("{}: {}".format("root", root))
  

def get_filenames(filearg, rootarg = None):
   """ 
   Parse the nuwebfile argument and produce
   the actual names of the inputfile, texfile, auxfile
   and root of the  path to the outputfiles to be produced
   Aborts processing when the inputfile cannot be opened.
   @param filearg: Filename as supplied by the user.
   @result: [ inputfilename, texfilename, auxfilename, outputfilename ] 
   """ 
   if rootarg:
      outroot = rootarg
   else:
      outroot = os.path.dirname(os.path.abspath(filearg))
   
   trunk, ext = os.path.splitext(filearg)
   if ext == "":
      inputfilename = trunk + ".w"
   elif (ext == ".tex") or (ext == ".aux"):
      logging.error("'.tex' or '.aux' are illegal extensions for the inputfile.")
      sys.exit(10)
      
   
   texfilename = trunk + ".tex"
   auxfilename = trunk + ".aux"
   
   if not os.access(inputfilename, os.R_OK):
       logging.error("Cannot read {}".format(inputfilename))
       sys.exit(10)
       
   
   return [inputfilename, texfilename, auxfilename, outroot ]



if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    
    parser = argparse.ArgumentParser(
        description = "Generate documents and code from a Nuweb source.")
    parser.add_argument("nuwebfile", help=helptext['nuwebfile'])
    parser.add_argument("-y", "--hyperopts", help=helptext['y'])
    parser.add_argument("-p", "--path", help=helptext['p'])
    parser.add_argument("-v", "--verbose", help=helptext["v"], action="store_true")
    
    parser.add_argument("-t", "--notex", help=helptext["t"], action="store_true")
    
    parser.add_argument("-o", "--no_out", help=helptext["o"], action="store_true")
    
    parser.add_argument("-d", "--no_dangling", help=helptext["d"], action="store_true")
    
    parser.add_argument("-c", "--no_compare", help=helptext["c"], action="store_true")
    
    parser.add_argument("-n", "--seqnumber", help=helptext["n"], action="store_true")
    
    parser.add_argument("-s", "--no_scraplist", help=helptext["s"], action="store_true")
    
    parser.add_argument("-x", "--xref", help=helptext["x"], action="store_true")
    
    
    args = parser.parse_args()
    rootarg = None
    if args.path:
      rootarg = args.path
    source_name, tex_name, aux_name, rootdir = \
        get_filenames(args.nuwebfile, rootarg = rootarg)
    
    list_options(source_name, tex_name, aux_name, rootdir)

