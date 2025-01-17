set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 {ndk_path}" >&2
  exit 1
fi

ndk_path=$1
dir=`dirname "$ndk_path"`

pushd "$dir" > /dev/null

if [[ -z "$DECLANG_HOME" ]]; then
  HOMEDIR=$HOME
else
  HOMEDIR=$DECLANG_HOME
fi
compiler_path="$HOMEDIR"/.DeClang/compiler

if [ "_$OS" = "_Windows_NT" ]; then # MSYS2
  ndk_clang_path=`find "$ndk_path" -type f -name "clang++.exe"`
elif uname -r | grep -i microsoft > /dev/null; then # WSL2
  ndk_clang_path=`find "$ndk_path" -type f -name "clang++.exe"`
else
  ndk_clang_path=`find "$ndk_path" -type f -name "clang++"`
fi

darwin_path=`dirname "$ndk_clang_path"`
darwin_path=`dirname "$darwin_path"`

if uname -r | grep -i microsoft > /dev/null; then # WSL2
  # backup bin
  if [[ ! -f "${darwin_path}"/bin/clang.orig.exe ]]; then
      cp "${darwin_path}"/bin/clang.exe "${darwin_path}"/bin/clang.orig.exe
  fi
  if [[ ! -f "${darwin_path}"/bin/clang++.orig.exe ]]; then
      cp "${darwin_path}"/bin/clang++.exe "${darwin_path}"/bin/clang++.orig.exe
  fi
  # copy bin
  cp -v "${compiler_path}"/bin/clang.exe "${darwin_path}"/bin/clang.exe
  cp -v "${compiler_path}"/bin/clang++.exe "${darwin_path}"/bin/clang++.exe
  
else # MSYS2 and others
  # backup bin
  if [[ ! -f "${darwin_path}"/bin/clang.orig ]]; then
      cp "${darwin_path}"/bin/clang "${darwin_path}"/bin/clang.orig
  fi
  if [[ ! -f "${darwin_path}"/bin/clang++.orig ]]; then
      cp "${darwin_path}"/bin/clang++ "${darwin_path}"/bin/clang++.orig
  fi
  # copy bin
  cp -v "${compiler_path}"/bin/clang "${darwin_path}"/bin/clang
  cp -v "${compiler_path}"/bin/clang++ "${darwin_path}"/bin/clang++
  
fi

# backup and copy lib
mkdir -p "${darwin_path}"/lib/
if [[ ! -d "${darwin_path}"/lib.orig ]]; then
  cp -r "${darwin_path}"/lib "${darwin_path}"/lib.orig
fi
cp -r "${compiler_path}"/lib/clang "${darwin_path}"/lib/

popd >/dev/null
