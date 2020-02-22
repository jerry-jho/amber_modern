import yaml
import sys
import argparse
import os
import re
import shutil

parser = argparse.ArgumentParser(description='yaml filelist processing')
parser.add_argument('-f','--file',type=str,help='imput filename')
parser.add_argument('-k','--keys',type=str,help='collection keys')
parser.add_argument('-s','--stype',type=str,default='vcs',help='output style, vcs for default')
parser.add_argument('-c','--command',type=str,default='list',help='output command, list for default')
parser.add_argument('-e','--expand_env',action='store_true',default=False,help='expand env')
#parser.add_argument('-o','--output',type=str,nargs='?',default=None,help='output file')


args = parser.parse_args()

ymlfile = args.file
keylist = args.keys

x = yaml.load(open(ymlfile))

o_options = []
o_defines = []
o_include = []
o_libpath = []
o_files   = []

for k in keylist.split(','):
    v = x[k]
    root = v.get('root','.')
    for i in v.get('options',[]):
        o_options.append(str(i))
    for i in v.get('defines',[]):
        #print("+define+%s" % i)
        o_defines.append(i)
    for i in v.get('libdirs',[]):
        o_libpath.append("%s/%s" % (root,i))
        #print("-y %s/%s" % )            
    for i in v.get('incdirs',[]):
        if i[0] == '$' or i[0] == '/' or i[0] == '.':
            o_include.append(i)
            #print("+incdir+%s" % i)
        else:
            o_include.append("%s/%s" % (root,i))
            #print("+incdir+%s/%s" % (root,i))
    for i in v.get('files',[]):
        if i[0] == '$' or i[0] == '/' or i[0] == '.':
            o_files.append(i)
            #print(i)
        else:
            o_files.append("%s/%s" % (root,i))
            #print("%s/%s" % (root,i))    
    
#print(ymlfile,keylist,root)

def sub_os_env(x):

    return os.environ.get(x[0][1:],x)

def expand_env(en,s):
    
    if not en:
        return s

    return re.sub(r'(\$[A-Za-z0-9_]+)',sub_os_env,s)

if args.command == 'list':
    
    if args.stype == 'vcs':
        print("\n".join(o_options))
        print("\n".join(["+define+%s" % expand_env(args.expand_env,k) for k in o_defines]))
        print("\n".join(["+incdir+%s" % expand_env(args.expand_env,k) for k in o_include]))
        print("\n".join(["-y %s" % expand_env(args.expand_env,k) for k in o_libpath]))
        print("\n".join([expand_env(args.expand_env,k) for k in o_files]))    
    elif args.stype == 'vivado':
        print("\n".join(["read_verilog -sv " + expand_env(args.expand_env,k) for k in o_files]))
        incdirs = ''
        if len(o_include) > 0:
            incdirs = ' -include_dirs {' + " ".join([expand_env(args.expand_env,k) for k in o_include]) + '}'
        print('set SYN_OPTIONS "' + " ".join(["-verilog_define %s" % expand_env(args.expand_env,k) for k in o_defines]) + incdirs + '"') 
elif args.command == 'concat':
    for d in o_defines:
        print("`define %s //%s" % (d.replace('=',' '),ymlfile))
    for f in o_files:
        sf = expand_env(True,f)
        if not os.path.exists(sf):
            sys.stderr.write("[ERROR] Cannot find %s\n",sf)
            exit(1)
        print("//!// concat from %s" % f)
        p = open(sf,'r')
        for i,line in enumerate(p):
            m = re.match("^\s*`include\s+\"([A-Za-z0-9\._\\\/]+)\"",line)
            if m:
                include_file = m.group(1)
                for x in ["%s/%s" % (expand_env(True,k),include_file) for k in o_include]:
                    #sys.stderr.write("[INFO] Check %s\n"%x)
                    if os.path.exists(x):
                        shutil.copyfile(x,'./' + os.path.basename(x))
                        sys.stderr.write("[INFO] Copy %s\n"%x)
                        break
                print("`include \"%s\" // %s" % (os.path.basename(include_file),line.strip()))
            else:
                print(line.replace("\n",""))