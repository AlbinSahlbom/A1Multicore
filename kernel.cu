//#include "kernel.cuh"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define N 32768

__host__
bool checkArr(int *arr, int size)
{
	for (int i = 0; i < size-1; ++i)
	{
		if (arr[i] > arr[i + 1])
		{
			printf("Array index: %d, with value: %d\nIs greater than index: %d, with value: %d\n", i, arr[i], i + 1, arr[i + 1]);
		}
	}
	return true;
}

__host__
void printArr(int *arr, int size)
{
	for (int i = 0; i < size - 1; ++i)
	{
		printf("%d, ", arr[i]);
	}
	printf("%d \n\n", arr[size - 1]);
}

__host__
void createRandArr(int *arr, int size, int maxVal)
{
	for (int i = 0; i < size; ++i)
	{
		int rnd = (rand() / (float)(RAND_MAX)) * maxVal;
		arr[i] = rnd;
	}
}

__host__
int oddeven(int *arr, int size, int oddeven)
{
	int sorted = 0;
	for (int i = oddeven; i < size-oddeven; i += 2)
	{
		int minStep = arr[i] > arr[i + 1];
		int min = arr[i + minStep];
		int maxStep = arr[i] <= arr[i + 1];
		int max = arr[i + maxStep];

		arr[i] = min;
		arr[i + 1] = max;

		sorted += minStep - maxStep;
	}
	return sorted;
}

__host__
void sortCPU(int *arr, int size)
{
	int i = 0;
	int sorted = 1;
	while (sorted != (-size+1))
	{
		sorted = oddeven(arr, size, i % 2);
		sorted += oddeven(arr, size, (i+1) % 2);
		i += 2;
	}
}

//__device__
//int oddevenGPU(int *d_arr, int size, int oddeven, int blockSize, int startIndex, int endIndex)
//{
//	int sorted = 0;
//	for (int i = startIndex; i < endIndex; i += 2)
//	{
//		int minStep = d_arr[i] > d_arr[i + 1];
//		int min = d_arr[i + minStep];
//		int maxStep = d_arr[i] <= d_arr[i + 1];
//		int max = d_arr[i + maxStep];
//
//		d_arr[i] = min;
//		d_arr[i + 1] = max;
//
//		sorted += minStep - maxStep;
//	}
//	return sorted;
//}
//
//__global__
//void addKernel(int *d_arr, int *d_size, int *d_blockSize, int *d_sorted)
//{
//	int size = *d_size;
//	int blockSize = *d_blockSize;
//	int nrThreads = size / blockSize;
//	int elemInThread = size / nrThreads;
//	int shift = elemInThread % 2;
//
//	int i = 0;
//	int sorted = 0;
//	int oddeven = 0;
//	while (sorted != (-size + 1))
//	{
//		sorted = 0;
//
//
//		oddeven = i % 2;	//0 == odd, 1 == even
//		int startIndex = blockSize * threadIdx.x + oddeven + (shift * ((threadIdx.x + 1) % 2) * threadIdx.x != 0);
//		int endIndex = blockSize + blockSize * threadIdx.x - oddeven + shift * ((threadIdx.x + 1)%2);
//
//		sorted += oddevenGPU(d_arr, size, oddeven, blockSize, startIndex, endIndex);
//		__syncthreads();
//
//
//		oddeven = (i + 1) % 2;
//		startIndex = blockSize * threadIdx.x + oddeven;
//		endIndex = blockSize + blockSize * threadIdx.x - oddeven;
//
//		sorted += oddevenGPU(d_arr, size, oddeven, blockSize, startIndex, endIndex);
//		__syncthreads();
//		i += 2;
//	}
//}



//__global__
//void addKernel(int *d_arr, int *d_size, int *d_blocksize, int *d_sorted)
//{
//	int i = blockIdx.x * threadIdx.x + threadIdx.x * 2;
//
//	int swaps = 0;
//	int oddevenRun = 0;
//
//	do
//	{
//		swaps += (d_arr[i] > d_arr[i + 1]);
//
//		int minStep = d_arr[i] > d_arr[i + 1];
//		int min = d_arr[i + minStep];
//		int maxStep = d_arr[i] <= d_arr[i + 1];
//		int max = d_arr[i + maxStep];
//
//		d_arr[i] = min;
//		d_arr[i + 1] = max;
//
//		if (i % 2 == 0)
//			++i;
//		else
//			--i;
//
//		oddevenRun = (oddevenRun + 1) * (oddevenRun != 2);
//		swaps = swaps * (swaps != 2);
//
//		__syncthreads();
//
//		*d_sorted -= 1 * (swaps != 0 * oddevenRun != 2);
//
//	} while (*d_sorted > 0);
//}


//int main()
//{
//	srand((unsigned int)time(NULL));
//
//	int size = 100;
//	int *arr = (int*)malloc(size * sizeof(int));
//	int *d_arr, *d_size, *d_blockSize, *d_sorted;
//	createRandArr(arr, size, size*2);
//
//	int n = 2;
//	int blockSize = size / n;
//
//	printArr(arr, size);
//	
//	cudaMalloc(&d_arr, size * sizeof(int));
//	cudaMalloc(&d_size, sizeof(int));
//	cudaMalloc(&d_blockSize, sizeof(int));
//	cudaMalloc(&d_sorted, sizeof(int));
//
//	cudaMemcpy(d_arr, arr, size * sizeof(int), cudaMemcpyHostToDevice);
//	cudaMemcpy(d_size, &size, sizeof(int), cudaMemcpyHostToDevice);
//	cudaMemcpy(d_blockSize, &blockSize, sizeof(int), cudaMemcpyHostToDevice);
//	cudaMemcpy(d_sorted, &size, sizeof(int), cudaMemcpyHostToDevice);
//
//	int nr = size / blockSize;
//	
//	addKernel<<<1, (size/2)>>>(d_arr, d_size, d_blockSize, d_sorted);
//	cudaMemcpy(arr, d_arr, size * sizeof(int), cudaMemcpyDeviceToHost);
//
//	printArr(arr, size);
//
//	/*printArr(arr, size);
//	sortCPU(arr, size);
//	printArr(arr, size);*/
//
//	system("pause");
//
//	cudaFree(d_arr);
//	cudaFree(d_size);
//	free(arr);
//	return 0;
//}



__global__
void oddeven(int *arr, int flag)
{
	int d_flag = flag%2;
	int index = (blockIdx.x * blockDim.x + threadIdx.x) * 2;
	if ((index >= N - 1) && d_flag != 0) return;	//Out of bounds

	index += d_flag;

	int min = arr[index + (arr[index] > arr[index + 1])];
	int max = arr[index + (arr[index] <= arr[index + 1])];

	arr[index] = min;
	arr[index + 1] = max;
}

int main()
{
	int *arr;
	int *d_arr;
	int i;
	int size = sizeof(int) * N;
	srand((unsigned)time(NULL));

	arr = (int*)malloc(size);

	cudaMalloc(&d_arr, size);

	createRandArr(arr, N, N * 2);

	//printArr(arr, N);

	double start_time = clock();

	cudaMemcpy(d_arr, arr, size, cudaMemcpyHostToDevice);

	for (i = 0; i<=N; i++)
	{
		oddeven<<<N / 2048, 1024>>>(d_arr, i);
	}

	cudaMemcpy(arr, d_arr, size, cudaMemcpyDeviceToHost);

	printf("\nExecution time: %lf seconds.\n", (clock() - start_time) / CLOCKS_PER_SEC);

	//printArr(arr, N);

	bool sorted = checkArr(arr, N);

	system("pause");

	return 0;
}