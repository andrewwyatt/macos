#!/bin/bash

###
### Just a simple script to install my apps and settings.
### It's a work in progress..
###

export BASEPATH=$(pwd)

if [ ! $1 ]
then
  export INSTALLTYPE="common"
else
  echo "Installing $1"
  export INSTALLTYPE="$1"
fi

echo "Installing: ${INSTALLTYPE}"
echo "Command Line: $*"

if [ -e "${BASEPATH}/${INSTALLTYPE}/include" ]
then
  for INCLUDE in $(cat ${BASEPATH}/${INSTALLTYPE}/include)
  do
    echo "Including: ${INCLUDE}"
    INSTALLTYPE="${INCLUDE} ${INSTALLTYPE}"
  done
fi 

echo "Caching the sudo credentials.."
sudo -v
### Sudo keepalive.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

### Common apps
echo "Installing Brew.."
which brew >/dev/null 2>&1
if [ ! "$?" = 0 ]
then
  echo "Installing Homebrew.."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

for KIND in ${INSTALLTYPE}
do
  ### If there are "type" directories, look for casks brew and mas files in them,
  ### and install them.
  if [ -e "${BASEPATH}/${KIND}/applists/casks" ]
  then
    echo "Installing ${KIND} casks.."
    for CASK in $(cat ${BASEPATH}/${KIND}/applists/casks | awk '/^[A-z0-9]/ {printf $1" "}')
    do
        brew cask list | grep ${CASK} >/dev/null 2>&1
        if [ ! $? == 0 ]
        then
          brew cask install --appdir="/Applications" ${CASK}
        else
          echo "${CASK} is already installed, skipping."
        fi
    done
  fi

  if [ -e "${BASEPATH}/${KIND}/applists/brew" ]
  then
    echo "Installing ${KIND} brew.."
    for BREW in $(cat ${BASEPATH}/${KIND}/applists/brew | awk '/^[A-z0-9]/ {printf $1" "}')
    do
        brew list | grep ${BREW} >/dev/null 2>&1
        if [ ! $? == 0 ]
        then
          brew install ${BREW}
        else
          echo "${BREW} is already installed, skipping."
        fi
    done
  fi

  if [ -e "${BASEPATH}/${KIND}/applists/mas" ]
  then
    echo "Installing ${KIND} apps from the app store.."
    for MAS in $(cat ${BASEPATH}/${KIND}/applists/mas | awk '/^[0-9]/ {printf $1" "}')
    do
      echo "Installing $(mas info ${MAS} | head -n 1)"
      brew mas list | grep ${MAS} >/dev/null 2>&1
      if [ ! $? == 0 ]
      then
        mas install "${MAS}"
      else
        echo "${MAS} is already installed, skipping."
      fi
    done
    echo "Upgrading Apple store apps.."
    mas upgrade
  fi

  if [ -d "${BASEPATH}/${KIND}/Applications" ]
  then
    echo "Copying ${KIND}/Applications to /Applications.."
    cp -rf ${BASEPATH}/${KIND}/Applications/*.app /Applications
  fi

  if [ -d "${BASEPATH}/${KIND}/scripts" ]
  then
    cd ${BASEPATH}/${KIND}/scripts
    for SCRIPT in *
    do
      bash ${SCRIPT}
    done
    cd ${BASEPATH}
  fi
done

echo "Testing to see if any apps need to be upgraded (when run after installing)."
brew upgrade
brew cask upgrade

echo "Moving formula based applications to /Applications"
find /usr/local | sed -e "s#/Con.*\$##" | grep "\.[Aa][Pp][Pp]\$" | uniq >/tmp/apps

while read APP
do
  NPAPP=$(echo ${APP} | sed -e "s#^/.*/##")
  if [ ! -d "/Applications/${NPAPP}" ]
  then
    mv "${APP}" /Applications
  fi
done </tmp/apps
rm -f /tmp/apps

# cleanup
brew cleanup
rm -rf /Library/Caches/Homebrew/*
