#!/bin/zsh

#Get info on the file and it's path
if [ -n "$1" ];then
  #The FILE variable exists to make sure escape sequences are stripped from the
  #input. The code to strip the input was found here: serverfault.com/a/71289
  FILE=$(printf "$1" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
  ABS_PATH="$(readlink -f $FILE)"
  FILENAME=$(basename "$ABS_PATH")
else
  printf "Missing argument.\n"
  exit 1
fi

CheckFilename ()
{ #Makes sure filename has CRC string
  LEN="${#FILENAME}"
  CRCSTART=$(($LEN - 12))
  CRCEND=$(($LEN - 5))
  CRC="$(printf $FILENAME | cut -b $CRCSTART-$CRCEND )"
  #Match $CRC to RegEx to make sure it's a real CRC,
  #else don't print anything.
  #--insert conditional and regex here--
  printf "$CRC"
}

VerifyCRC ()
{ #Check the CRC  of the file against the CRC in the filename
  CRC1="$1"
  CRC2="$(cksfv -q $ABS_PATH | tail -c 9)"
  if [ "$CRC1" = "$CRC2" ];then
    printf "CRCs match\n"
  else
    printf "CRC mismatch\n"
  fi
}

CheckCRC ()
{
  if [  -n "$1" ];then
    CRCCHECK=$(CheckFilename "$FILENAME")
    if [ -n "$CRCCHECK" ];then
      VerifyCRC $CRCCHECK
    else
      printf "No CRC found in filename.\n"
    fi
  else
    printf "Missing argument.\n"
  fi
}

ARGCOUNT=0
for i in $@
do
  if [ -n "$i" ];then
    #The FILE variable exists to make sure escape sequences are stripped from
    #the input. The code to strip the input was found here:
    #serverfault.com/a/71289
    FILE=$(printf "$1" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
    ABS_PATH="$(readlink -f $FILE)"
    FILENAME=$(basename "$ABS_PATH")
    CheckCRC "$i"
  fi
done
