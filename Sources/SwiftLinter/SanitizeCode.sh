#!/bin/sh

# Print script header
cat << EOL

██╗ ██████╗ ███████╗    ██╗    ██╗ █████╗ ██╗     ██╗     ███████╗████████╗           
██║██╔═══██╗██╔════╝    ██║    ██║██╔══██╗██║     ██║     ██╔════╝╚══██╔══╝           
██║██║   ██║███████╗    ██║ █╗ ██║███████║██║     ██║     █████╗     ██║              
██║██║   ██║╚════██║    ██║███╗██║██╔══██║██║     ██║     ██╔══╝     ██║              
██║╚██████╔╝███████║    ╚███╔███╔╝██║  ██║███████╗███████╗███████╗   ██║              
╚═╝ ╚═════╝ ╚══════╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝              
██████╗ ██╗   ██╗██╗██╗     ██████╗     ████████╗ ██████╗  ██████╗ ██╗     ███████╗██╗
██╔══██╗██║   ██║██║██║     ██╔══██╗    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝██║
██████╔╝██║   ██║██║██║     ██║  ██║       ██║   ██║   ██║██║   ██║██║     ███████╗██║
██╔══██╗██║   ██║██║██║     ██║  ██║       ██║   ██║   ██║██║   ██║██║     ╚════██║╚═╝
██████╔╝╚██████╔╝██║███████╗██████╔╝       ██║   ╚██████╔╝╚██████╔╝███████╗███████║██╗
╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚═╝

EOL

# Constants
Base="${BUILD_DIR%Build/*}SourcePackages/checkouts/SwiftLinter/Sources"
SwiftLint="$Base/SwiftLinter"

cd $Base

printf "%-9s %s\n" "Version:" "1.0.8 - April 21, 2021"
printf "%-9s %s\n" "SHA1:" "$(git rev-parse HEAD)"
printf "%-9s %s\n" "Tag:" "$(git describe --tags --long)"
printf "%-9s %s\n" "Folder:" $1
printf "﹏﹏﹏﹏\n\n"

# Parse Flag Inputs

while getopts "L" FLAG; do
  case "$FLAG" in
    L) # Check for the lint only flag and update the variable 
      lintOnly=true
      ;;
    \?) 
      echo "Invalid option: -$OPTARG. Use -L to lint the code."
      exit
      ;;
  esac
done

# Make sure SwiftLint exists and lint the code based on our custom SwiftLint rules
if [[ -f $SwiftLint/swiftlint && -f $SwiftLint/rules.yml ]]; then
  export PATH="$SwiftLint:$PATH" # Make sure we use the executable from the BuildTools repo first, to avoid using any versions installed on the machine
  cd $SwiftLint

  printf "🚨🚨 SwiftLint 🚨🚨\n"
  printf "%-9s %s\n" "Binary:" "$(which swiftlint)"
  printf "%-9s %s\n" "Version:" "$(swiftlint version)"
  printf "%-9s %s\n" "Rules:" "SwiftLint/rules.yml"
  
  if [ "$2" = "lint" ]; then
    swiftlint --quiet --config "$SwiftLint/rules.yml" --path $1 # --quiet keeps the SwiftLint output out of stderr which causes issues with ADO pipelines
    # If SwiftLint finds any issues, fail the build and tell the developer.
    if [ $? -ne 0 ]; then
      echo "error: Linting failed! Fix the warnings and try again :)"
      exit 1
    fi
  else
    swiftlint --fix --config "$SwiftLint/rules.yml" --path $1
    swiftlint --strict --config "$SwiftLint/rules.yml" --path $1
  fi
  
  printf "﹏﹏﹏﹏\n\n"
  
else
  printf "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
  echo "${PWD##*/}"
  echo "error: SwiftLint executable or rules missing from expected directory."
  echo "Expected Directory: " + $SwiftLint/swiftlint
  printf "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
  exit 1
fi
