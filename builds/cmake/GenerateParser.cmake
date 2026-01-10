# GenerateParser.cmake - Cross-platform parser preprocessing
#
# This script replaces the Unix sed commands used to preprocess parse.y
# before running btyacc. It extracts %type lines to types.y and removes
# them from the main file to create y.y.
#
# Required variables:
#   PARSE_Y_FILE - Path to parse.y
#   OUTPUT_DIR   - Directory for output files (y.y, types.y)

if(NOT DEFINED PARSE_Y_FILE)
    message(FATAL_ERROR "PARSE_Y_FILE not defined")
endif()

if(NOT DEFINED OUTPUT_DIR)
    message(FATAL_ERROR "OUTPUT_DIR not defined")
endif()

# Read parse.y content
file(READ "${PARSE_Y_FILE}" parse_content)

# Pattern to match %type lines (including multiline continuations)
# Original sed: sed -n "/%type .*/p" - prints lines matching %type
# We need to extract all lines starting with %type

# Extract %type lines to types.y
# Match lines that start with %type (possibly with leading whitespace)
string(REGEX MATCHALL "[^\n]*%type [^\n]*" type_lines_list "${parse_content}")
list(JOIN type_lines_list "\n" types_content)
if(types_content)
    string(APPEND types_content "\n")
endif()
file(WRITE "${OUTPUT_DIR}/types.y" "${types_content}")

# Remove %type lines from content to create y.y
# Original sed: sed "s/%type .*//" - removes %type and everything after on each line
# This replaces "%type ..." with empty string on each matching line
string(REGEX REPLACE "%type [^\n]*" "" y_content "${parse_content}")
file(WRITE "${OUTPUT_DIR}/y.y" "${y_content}")

message(STATUS "GenerateParser: Created types.y and y.y from parse.y")
