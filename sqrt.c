#include <stdio.h>
#include <math.h>
#include <windows.h>


// Main function prototypes:

float SquareRoot(float x);
float __stdcall InverseSquareRoot(float x);



// These defines determine the size of the lookup tables and hence the accuracy
// If you want them to differ then you need to define two of the tab_in and tab_out
// structures so that the two lookup tables get built in slightly different ways.
#define SQRT_TABLE_ENTRY_BITS			10
//#define INVSQRT_TABLE_ENTRY_BITS		10


// These three are the bit counts in a 32 bit IEEE floating point number
#define MANTISSA_BITS				23
#define EXPONENT_BITS				8
#define SIGN_BITS					1

// There's a good reason for the bias - but I'm not going to explain it here.
#define EXPONENT_BIAS				127
#define EXPONENT_MASK				(((1 << EXPONENT_BITS) - 1) << MANTISSA_BITS)

//How many bits of mantissa go into the look up table, more is equivalent to higher accuracy
#define SQRT_TABLE_SEED_MANT_BITS	(SQRT_TABLE_ENTRY_BITS - 1)
#define SQRT_TABLE_SEED_EXP_BITS	1
#define SQRT_TABLE_LENGTH_BITS		(SQRT_TABLE_SEED_MANT_BITS + SQRT_TABLE_SEED_EXP_BITS)
#define SQRT_TABLE_NUM_ENTRIES		(1 << SQRT_TABLE_LENGTH_BITS)

// How to extract the exponent of an IEEE float
#define EXP_OF(x)	(*(DWORD *)&(x) & EXPONENT_MASK)

typedef struct _tab_in
{
	DWORD mpad:		((MANTISSA_BITS + 1) - SQRT_TABLE_LENGTH_BITS);
	DWORD lookup:	SQRT_TABLE_LENGTH_BITS;
	DWORD epad:		(EXPONENT_BITS - SQRT_TABLE_SEED_EXP_BITS);
	DWORD spad:		(SQRT_TABLE_SEED_EXP_BITS);
} tab_in;

typedef struct _tab_out
{
	DWORD mpad:		(MANTISSA_BITS - SQRT_TABLE_ENTRY_BITS);
	DWORD lookup:	SQRT_TABLE_ENTRY_BITS;
	DWORD epad:		EXPONENT_BITS;
	DWORD spad:		SIGN_BITS;
} tab_out;

union myfp
{
	float fp;

	//used to build the lookup tables
	tab_in	tab_in_;
	tab_out	tab_out_;
};


DWORD InvSqrtTab[SQRT_TABLE_NUM_ENTRIES];
DWORD SqrtTab[SQRT_TABLE_NUM_ENTRIES];


#pragma optimize("g", on)

void
BuildInvSqrtTable()
{
	static int done = 0;
	int i;

	if (done) return;
	done = 1;

	for (i = 0; i < SQRT_TABLE_NUM_ENTRIES; i++) {
		union myfp fin, fout;

		fin.fp = 1.0f;
		fin.tab_in_.lookup = i;

		// calculate the real value.
		fout.fp = 1.0f / (float)sqrt((double)fin.fp);

		// Add the value to the table.  1.0 requires special treatment.
		if (fout.fp == 1.0f)
			InvSqrtTab[i] = 0x3FF << (MANTISSA_BITS - SQRT_TABLE_ENTRY_BITS);
		else
			InvSqrtTab[i] = fout.tab_out_.lookup << (MANTISSA_BITS - SQRT_TABLE_ENTRY_BITS);
	}
} // BuildInvSqrtTable()

void
BuildSqrtTable()
{
	static int done = 0;
	int i;

	if (done) return;
	done = 1;

	for (i = 0; i < SQRT_TABLE_NUM_ENTRIES; i++) {
		union myfp fin, fout;

		fin.fp = 1.0f;
		fin.tab_in_.lookup = i;

		// calculate the real value.
		fout.fp = (float)sqrt((double)fin.fp);

		// Add the value to the table.  1.0 requires special treatment.
		if (fout.fp == 1.0f)
			SqrtTab[i] = 0x0 << (MANTISSA_BITS - SQRT_TABLE_ENTRY_BITS);
		else
			SqrtTab[i] = fout.tab_out_.lookup << (MANTISSA_BITS - SQRT_TABLE_ENTRY_BITS);
	}
} // BuildSqrtTable()


float __stdcall
InverseSquareRoot(float x)
{
	DWORD index;
	float r;
	DWORD *dptr = (DWORD *)&r;

	*(DWORD *)&r = ((((3 * EXPONENT_BIAS - 1) << MANTISSA_BITS) - EXP_OF(x)) >> 1) & EXPONENT_MASK;

	index = ((*(DWORD *)&x) >> (MANTISSA_BITS - SQRT_TABLE_ENTRY_BITS + 1))
			& (SQRT_TABLE_NUM_ENTRIES - 1);
	*dptr |= InvSqrtTab[index];
	return r;
} //InverseSquareRoot()


float SquareRoot(float x)
{
	DWORD index;
	float r;
	DWORD *dptr = (DWORD *)&r;
	
	*(DWORD *)&r = (((EXPONENT_BIAS << MANTISSA_BITS) + EXP_OF(x)) >> 1) & EXPONENT_MASK;

	index = ((*(DWORD *)&x) >> (MANTISSA_BITS - SQRT_TABLE_ENTRY_BITS + 1))
			& (SQRT_TABLE_NUM_ENTRIES - 1);
	*dptr |= SqrtTab[index];

	// One iteration of Newton Raphson's method will double the accuracy
	r = (3.0f - (r * r) / x) * r * 0.5f;

	return r;
} // SquareRoot()


// Then some sample test code...
//  If you don't want this then simply remove it, along
//  with the "#include" lines at the start of the file.

int
main(int argc, char **argv)
{
	float f, r;

	BuildSqrtTable();
	BuildInvSqrtTable();

	printf("Tables completed\n");

	for (f = 0.0001f; f < 10000.0f; f *= 1.5) {
		r = SquareRoot(f);
		printf("SquareRoot(%f) = %f (C=%f)\n", f, r, (float)sqrt(f));
	}

	for (f = 0.0001f; f < 10000.0f; f *= 1.5) {
		r = InverseSquareRoot(f);
		printf("InverseSquareRoot(%f) = %f (C=%f)\n", f, r, (float)(1.0f/sqrt(f)));
	}

	return 0;
} // main()

