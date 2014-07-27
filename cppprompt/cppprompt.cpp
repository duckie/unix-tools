#include <array>
#include <cassert>
#include <deque>
#include <iomanip>
#include <iostream>
#include <regex>
#include <sstream>
#include <string>
#include <tuple>
#include <vector>

using std::array;
using std::deque;
using std::for_each;
using std::istringstream;
using std::ostringstream;
using std::setfill;
using std::setw;
using std::string;
using std::size_t;
using std::pair;
using std::istringstream;
using std::vector;

struct ColorCodes {
  string blank;
  string complete_folder;
  string truncated_folder;
  string folder_sep;
};

int main(int argc, char* argv[]) {

  // Check command line arguments
  if (argc < 4) {
    std::cerr << "Usage: " << argv[0] << " $? $(pwd) max_size" << std::endl;
    return 2;
  }

  // Converting command line arguments
  int return_code = std::atoi(argv[1]);
  string current_dir(argv[2]);
  int max_size = std::atoi(argv[3]);
  if (max_size < 9) {
    std::cerr << "Max size must be at least 9 (" << max_size << " given)." << std::endl;
    return 2;
  }

  ColorCodes codes;
  if(5 < argc) {
    array<string,5> extracted_codes;
    for(int index = 4; index < argc-!(argc%2); index+=2) {
      string key(argv[index]);
      string val(argv[index+1]);
      if(key == "--color") {
        istringstream input(val);
        for(int index = 0; index < extracted_codes.size() && getline(input, val, ':'); ++index) extracted_codes[index] = val;
        codes = {extracted_codes[0], extracted_codes[1], extracted_codes[2], extracted_codes[3]};
      }
    }
  }

  // Tokenizing the path
  vector<pair<string, size_t>> tokens;
  istringstream tokenizer_stream(current_dir);
  string token;
  while (std::getline(tokenizer_stream, token, '/')) {
    if (token.size()) tokens.emplace_back(token, token.size());
  }

  size_t nb_tokens = tokens.size();
  int dir_list_max_size = max_size - 7;

  if (nb_tokens) {
    // Searching the optimized directory string
    // Finding the best number of complete tokens
    size_t nb_complete= 0 ;
    size_t size_rep = 2*tokens.size();
    while (size_rep <= dir_list_max_size && nb_complete < nb_tokens) {
      ++nb_complete;
      size_rep += (tokens[nb_tokens-nb_complete].second-1);
    }
    if (0 < nb_complete && (nb_complete < tokens.size() || dir_list_max_size < size_rep)) {
      size_rep -= (tokens[nb_tokens - nb_complete].second-1);
      --nb_complete;
    }

    // Fitting
    if (nb_complete < nb_tokens) {
      size_t index = 0;
      for(auto& token : tokens) {
        if (index < tokens.size() - nb_complete) 
          token.second = 1;
        else
          break;
        ++index;
      }

      size_t slots_remaining = dir_list_max_size - size_rep;
      size_t nb_truncated = tokens.size() - nb_complete;
      size_t nb_truncated_filled = 0;
      index = nb_truncated-1;

      while(slots_remaining) {
        if (tokens[index].second < tokens[index].first.size()) {
          ++tokens[index].second;
          --slots_remaining;
        }

        --index;
        if (nb_truncated -1 < index)
          index = nb_truncated - 1;
      }
    }
  }
  else {
    tokens.emplace_back("",0);
  }

  // Rendering
  size_t size_rep = 0;
  size_t not_printable_str_size = 0;
  ostringstream dir_rep;
  for(auto const& token : tokens) {
    dir_rep << codes.folder_sep << "/" << codes.truncated_folder << token.first.substr(0,token.second);
    size_rep += token.second;
    not_printable_str_size += codes.folder_sep.size() + codes.truncated_folder.size();
  }

  // Printing the prompt
  std::cout << "[" << setfill('0') << setw(3) << return_code << "]";
  std::cout << "(" << setfill('.') << setw(dir_list_max_size + not_printable_str_size) << dir_rep.str() << ")";
  std::cout << std::endl;

  return 0;
}
