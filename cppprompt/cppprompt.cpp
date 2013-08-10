#include <array>
#include <cassert>
#include <deque>
#include <iomanip>
#include <iostream>
#include <regex>
#include <sstream>
#include <string>
#include <tuple>

using std::array;
using std::deque;
using std::for_each;
using std::istringstream;
using std::ostringstream;
using std::setfill;
using std::setw;
using std::string;

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
	deque<string> path;
	for (char current_char : current_dir) {
		if(current_char == '/') path.push_back("");
		else path.back() += current_char; 
	}

	deque<char> truncated_path;
	for_each(path.begin(), path.end(), [&](string const& s){ truncated_path.push_back(s[0]); });

	// Searching the optimized directory string
	int dir_list_max_size = max_size - 7;
	//string dir_rep;
  ostringstream dir_rep;
  string dir_str;
  int invisible_str_size = 0;
	bool leading_truncated = false;
	assert(2 <= dir_list_max_size);
	// Case of root directory
	if (0 == path.size() || (1 == path.size() && 0 == path[0].size())) {
		dir_rep << codes.folder_sep << "/" << codes.blank;
    invisible_str_size += codes.folder_sep.size() + codes.blank.size();
	}
	else {
		int nb_complete = 0;
		int nb_truncated = truncated_path.size();

		int nb_complete_candidate = 1;
		bool too_long_candidate_found = false;
		while(!too_long_candidate_found && nb_complete_candidate <= path.size()) {
			int size_rep = 0;
			for_each(path.end() - nb_complete_candidate, path.end(), [&](string const& s) { size_rep += s.size()+1; });
			size_rep += 2*(nb_truncated - nb_complete_candidate);
			if(dir_list_max_size < size_rep) {
				too_long_candidate_found = true;
			}
			if(!too_long_candidate_found) ++nb_complete_candidate;
		}
    int size_rep = 0;
		nb_complete = nb_complete_candidate - 1;
		nb_truncated -= nb_complete;
	
		for_each(truncated_path.begin(), truncated_path.begin()+nb_truncated, [&](char c){ 
			dir_rep << codes.folder_sep << "/" << codes.truncated_folder << c; 
      size_rep +=2;
      invisible_str_size += codes.folder_sep.size() + codes.truncated_folder.size();
		});
		for_each(path.end() - nb_complete, path.end(), [&](string & s){ 
			dir_rep << codes.folder_sep << "/" << codes.complete_folder << s; 
      size_rep += (1+s.size());
      invisible_str_size += codes.folder_sep.size() + codes.complete_folder.size();
		});
    dir_rep << codes.blank;
    dir_str = dir_rep.str();
    invisible_str_size += codes.blank.size();
		if(dir_list_max_size < size_rep) {
			dir_str = dir_str.substr(size_rep - dir_list_max_size);
			dir_str[0] = '*'; 
		}
	}

	// Printing the prompt
	std::cout << "[" << setfill('0') << setw(3) << return_code << "]";
	std::cout << "(" << setfill('.') << setw(dir_list_max_size + invisible_str_size) << dir_str << ")";
	
	std::cout << std::endl;
  return 0;	
}
