#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <executable>"
    exit 1
fi

executable="$1"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    system_libs=$(otool -L "$executable" | awk '{print $1}' | grep -E '^/usr/lib|^/System/Library')
    # Get the list of shared libraries linked against the executable
    libs=$(otool -L "$executable" | awk '{print $1}')
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    system_libs=$(ldd "$executable" | awk '{print $1}' | grep -E '^/lib|^/usr/lib')
    # TODO: Test
    libs=$(ldd "$executable" | awk '{print $1}')
elif [[ "$OSTYPE" == "msys" ]]; then
    # Windows (using Git Bash)
    system_libs=$(objdump -p "$executable" | grep 'DLL Name:' | awk '{print $3}' | grep -E '^/c/Windows|^/c/WINDOWS|^/c/Program\ Files|^/c/Program\ Files\ \(x86\)')
    # TODO: Test
    libs=$(objdump -p "$executable" | awk '{print $1}')
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi


# Filter out the system libraries
non_system_libs=$(comm -23 <(echo "$libs" | sort) <(echo "$system_libs" | sort))

if [ -n "$non_system_libs" ]; then
    echo "The executable $executable is dynamically linked to the following non-system libraries:"
    echo "$non_system_libs"
    exit 1
else
    echo "The executable $executable is dynamically linked only to system libraries."
    exit 0
fi