# FixParserTokens.cmake - Cross-platform token prefix fixing
#
# This script replaces the Unix sed commands that add TOK_ prefix to
# token definitions in y_tab.h after btyacc generates it.
#
# Original sed commands:
#   sed -i "s/#define \([A-Z].*\)/#define TOK_\1/g" y_tab.h
#   sed -i "s/#define TOK_YY\(.*\)/#define YY\1/g" y_tab.h
#
# Required variables:
#   OUTPUT_DIR - Directory containing y_tab.h

if(NOT DEFINED OUTPUT_DIR)
    message(FATAL_ERROR "OUTPUT_DIR not defined")
endif()

set(Y_TAB_H "${OUTPUT_DIR}/y_tab.h")

if(NOT EXISTS "${Y_TAB_H}")
    message(FATAL_ERROR "y_tab.h not found at ${Y_TAB_H}")
endif()

# Read y_tab.h content
file(READ "${Y_TAB_H}" header_content)

# Step 1: Add TOK_ prefix to all #define lines starting with uppercase letters
# Original sed pattern: s/#define \([A-Z].*\)/#define TOK_\1/g
# This matches #define followed by uppercase letter and everything after
string(REGEX REPLACE "#define ([A-Z][^\r\n]*)" "#define TOK_\\1" header_content "${header_content}")

# Step 2: Remove TOK_ prefix from YY* defines (yacc internal defines)
# These were incorrectly prefixed in step 1, so we need to undo it
string(REGEX REPLACE "#define TOK_YY" "#define YY" header_content "${header_content}")

# Write the modified content back
file(WRITE "${Y_TAB_H}" "${header_content}")

message(STATUS "FixParserTokens: Added TOK_ prefix to token definitions in y_tab.h")
