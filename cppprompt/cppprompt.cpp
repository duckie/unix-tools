#include <string>
#include <sstream>
#include <iostream>
#include <regex>
#include <deque>
#include <cassert>
#include <iomanip>

using std::string;
using std::deque;
using std::for_each;
using std::setfill;
using std::setw;

int main(int argc, char* argv[]) {
	// Check command line arguments
	if (argc != 4) {
		std::cerr << "Usage: " << argv[0] << " $(pwd) $? max_size" << std::endl;
		return 2;
	}

	// Converting command line arguments
	string current_dir(argv[1]);
	int return_code = std::atoi(argv[2]);
	int max_size = std::atoi(argv[3]);
	if (max_size < 9) {
		std::cerr << "Max size must be at least 9 (" << max_size << " given)." << std::endl;
		return 2;
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
	string dir_rep;
	bool leading_truncated = false;
	assert(2 <= dir_list_max_size);
	// Case of root directory
	if (0 == path.size() || (1 == path.size() && 0 == path[0].size())) {
		dir_rep = "/";
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
		nb_complete = nb_complete_candidate - 1;
		nb_truncated -= nb_complete;
	
		for_each(truncated_path.begin(), truncated_path.begin()+nb_truncated, [&](char c){ 
			dir_rep += "/"; dir_rep += c; 
		});
		for_each(path.end() - nb_complete, path.end(), [&](string & s){ 
			dir_rep += "/"; dir_rep += s; 
		});

		if(dir_list_max_size < dir_rep.size()) {
			dir_rep = dir_rep.substr(dir_rep.size() - dir_list_max_size);
			dir_rep[0] = '*'; 
		}
	}

	// Printing the prompt
	std::cout << "[" << setfill('0') << setw(3) << return_code << "]";
	std::cout << "(" << setfill('/') << setw(dir_list_max_size) << dir_rep << ")";
	
	std::cout << std::endl;
  return 0;	
}
