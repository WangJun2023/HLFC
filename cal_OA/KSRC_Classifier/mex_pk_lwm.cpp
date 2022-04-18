// local weight mean kernel
#include "mex.h"
#include <SDKDDKVer.h>
#include <stdio.h>
#include <tchar.h>
#include <ppl.h>
using namespace Concurrency;

typedef double DAT;
typedef double INT;
template <class T>
void delete_matrix(T **pVal, int n)
{
	for (int i=0; i<n; i++)
	{	
		delete [] pVal[i]; 
		pVal[i] = 0;
	}
	delete [] pVal; 
	pVal = 0;
}

void lwm
(
int n, 
int nWind, 
int train_size,
int test_size,
int Kbuf_rows,
int Kbuf_cols, 
double *pVal, 
DAT *Kbuf,
DAT *train_weight, 
INT *w_train,
INT *w_train_size,
DAT *test_weight,
INT *w_test,
INT *w_test_size
)
{
	double *pVal_n = pVal + n;
	int n_w_train_size = (int)w_train_size[n];
	INT *x1 = w_train + n*nWind;
	DAT *n_train_weight = train_weight + n*nWind;
	DAT **K1 = new DAT*[Kbuf_cols];
		for (int i=0; i<Kbuf_cols; i++)
		{
			K1[i] = new DAT[n_w_train_size];
			if (!K1[i]) mexErrMsgTxt("Memory allocation failure\n");
			DAT *Kbuf_i = Kbuf + i*Kbuf_rows;
			for (int j=0; j<n_w_train_size; j++)
			{
				int nx1 = (int)x1[j] - 1;	
				K1[i][j] = n_train_weight[j] * Kbuf_i[nx1];
			}
		}
		for (int m=0; m<test_size; m++)
		{
			int m_w_test_size = (int)w_test_size[m];
			INT *x2 = w_test + m*nWind; 
			DAT *m_test_weight = test_weight + m*nWind;
			DAT nSum = 0.0;
			for (int i=0; i<m_w_test_size; i++)
			{
				int nx2 = (int)x2[i] - 1;
				DAT *K1_nx2 = K1[nx2]; 
				DAT tmp = 0.0;
				for (int j=0; j<n_w_train_size; j++)
				{
					tmp += *(K1_nx2++);
				}
				nSum += (tmp * m_test_weight[i]);
			}
			*(pVal_n + m*train_size) = (double)nSum;
		}
		delete_matrix(K1, Kbuf_cols);
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////// main function //////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	const mxArray *mx;
	int rhs = 0;
	mx = prhs[rhs++]; // Kbuf, DAT 2 dim
	int Kbuf_rows = (int)mxGetM(mx); int Kbuf_cols = (int)mxGetN(mx);
	DAT *Kbuf = (DAT*)mxGetData(mx);
	
	/* w_train w_train_size train_weight 
	   w_test w_test_size test_weight */
	mx = prhs[rhs++]; // w_train, INT 2 dim
	int nWind = (int)mxGetM(mx); int train_size = (int)mxGetN(mx);
	INT *w_train = (INT*)mxGetData(mx);
	mx = prhs[rhs++]; // w_train_size, INT 1 dim
	INT *w_train_size = (INT*)mxGetData(mx);
	mx = prhs[rhs++]; // train_weight, DAT 2 dim
	DAT *train_weight = (DAT*)mxGetData(mx);
	mx = prhs[rhs++]; // w_test, INT 2 dim
	int test_size = (int)mxGetN(mx);
	INT *w_test = (INT*)mxGetData(mx);
	mx = prhs[rhs++]; // w_test_size, INT 1 dim
	INT *w_test_size = (INT*)mxGetData(mx);
	mx = prhs[rhs++]; // test_weight DAT 2 dim
	DAT *test_weight = (DAT*)mxGetData(mx);
	mx = prhs[rhs++];
	int nPal = (int)mxGetScalar(mx);
	
	/* return value */
	plhs[0] = mxCreateDoubleMatrix(train_size, test_size, mxREAL);
	mx = plhs[0];
	double *pVal = mxGetPr(mx);
	
	// main loop
	if (nPal == 1)
	{
		structured_task_group tasks;
		tasks.run_and_wait([&]
		{
			parallel_for(int(0), int(train_size), [&](int n)
			{
				lwm(n, nWind, train_size, test_size, Kbuf_rows, Kbuf_cols, pVal, Kbuf, 
					train_weight, w_train, w_train_size, test_weight, w_test, w_test_size);
			});
		});
	}
	else
	{
		for (int n=0; n<train_size; n++)
		{
			lwm(n, nWind, train_size, test_size, Kbuf_rows, Kbuf_cols, pVal, Kbuf, 
				train_weight, w_train, w_train_size, test_weight, w_test, w_test_size);
		}
	}

}