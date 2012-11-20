#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[]) {
	ifstream inFile;
	inFile.open(argv[1],ifstream::binary);
	
	// Read in PE binary
	vector<unsigned int> pileOfBytes;
	while (inFile.good()) {
		pileOfBytes.push_back(inFile.get());
	}
	inFile.close();
	cout << pileOfBytes.size() << endl;
	
	ofstream outFile;
	outFile.open("out.v");
	outFile << "Require Import Coq.Lists.List.\n";
	outFile << "Require Import ZArith.\n";
	outFile << "Require Import Bits.\n";
	outFile << "Require Import PETraversal.\n\n";
	outFile << "Open Scope Z_scope.\n\n";
	outFile << "Notation \" [ x , .. , y ] \" := (cons x .. (cons y nil) ..).\n\n";
	
	int max = 0;
	for (int i = 0; i < pileOfBytes.size()-1; i+=3072) {
		max++;
		outFile << "Definition zs" << (i/3072) << " := [";

		for (int j = 0; (j < 3072) && (i+j) < pileOfBytes.size()-1; j++) {
			if (j > 0) {
				outFile << ", ";
			}
			if (j%16 == 0) {
				outFile << "\n     ";
			}
			outFile << pileOfBytes[i+j];
		}
		outFile << "].\n\n";
	}
	/*outFile << "Definition zs := [";
	for (int i = 0; i < pileOfBytes.size()-1; i++) {
		if (i > 0) {
			outFile << ", ";
		}
		if (i%16 == 0) {
			outFile << "\n     ";
		}
		outFile << pileOfBytes[i];
	}
	outFile << "].\n\n";*/
	
	outFile << "Fixpoint zstois (l : list Z) : list int8 :=\n";
	outFile << "   match l with\n";
	outFile << "   | nil => nil\n";
	outFile << "   | x::xs => (Word.repr x)::(zstois xs)\n";
	outFile << "end.\n\n";
	
	outFile << "Fixpoint zlstoils (l : list (list Z)) : list (list int8) :=\n";
	outFile << "   match l with\n";
	outFile << "   | nil => nil\n";
	outFile << "   | h::t => (zstois h)::(zlstoils t)\n";
	outFile << "end.\n\n";
	
	outFile << "Definition zs := ";
	for (int i = 0; i < max; i++) {
		if (i == 0) {
			outFile << "zs0";
		} else {
			outFile << "::zs" << i;
		}
	}
	outFile << "::nil.\n\n";

	outFile << "Definition bytes := zlstoils zs.\n\n";
	outFile << "Definition mask : int32 := Word.repr 268435440.\n";
	//outFile << "Compute checkExports bytes mask.\n\n";
	//outFile << "Definition addresses := getExports bytes.\n";
	//outFile << "Compute addresses.";
	outFile.close();
}
