import string, re, os, subprocess, sys

# This script generates reformat the output of git log to the 
# format of release note.
# Example 
# 
#    * <commit subject>
#    + 
#    <commit message>
#
#    Bug: issue 123
#    Change-Id: <change id>
#    Signed-off-by: <name>
# Expected Output:
#
#    * issue 123 <commit subject>
#    + 
#    <commit message>
#


fin = open(sys.argv[1])
fout = open('ReleaseNote', sys.argv[2])

subject = ""
message = []

for line in fin:
    
    if re.match('\* ', line) >= 0:
        
        if subject != "":
            # Write output
            fout.write(subject)
            
            if message != []:
                message[-1] = '\n'
            for m in message:
                fout.write(m)
            
        # Start new commit block
        message = []
        subject = line
        continue
    
    elif re.match('Bug: ', line) >= 0:
        
        subject = subject[:2] + line.replace('Bug:', '').replace('\n',' ') + subject[2:]
        
    elif re.match('Issue: ', line) >= 0:
        subject = subject[:2] + line.replace('Issue:', 'issue').replace('\n',' ') + subject[2:]   
    
    elif re.match('Change-Id:', line) >= 0:
        continue
    elif re.match('Signed-off-by:', line) >= 0:
        continue 
    
    else:
        if line == '\n':
            if message[-1] != '+\n':
                message.append('+\n')
        else:    
            message.append(line)
