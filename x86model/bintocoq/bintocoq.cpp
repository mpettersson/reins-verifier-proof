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
	outFile << "Require Import Bits.\n\n";
	outFile << "Open Scope Z_scope.\n\n";
	outFile << "Notation \" [ x , .. , y ] \" := (cons x .. (cons y nil) ..).\n\n";
	
	outFile << "Definition zs := [";
	for (int i = 0; i < pileOfBytes.size()-4; i+=4) {
		if (i > 0) {
			outFile << ", ";
		}
		if (i%12 == 0) {
			outFile << "\n     ";
		}
		outFile << pileOfBytes[i+1] << ", " << pileOfBytes[i] << ", ";
		outFile << pileOfBytes[i+3] << ", " << pileOfBytes[i+2];
	}
	outFile << "].\n\n";
	
	outFile << "Fixpoint zstois (l : list Z) : list int8 :=\n";
	outFile << "   match l with\n";
	outFile << "   | nil => nil\n";
	outFile << "   | x::xs => (Word.repr x)::(zstois xs)\n";
	outFile << "end.\n\n";
	
	outFile << "Definition bytes := zstois zs.\n";
	outFile.close();
}