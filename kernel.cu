//#include "kernel.cuh"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

void printArr(int *arr, int size)
{
	for (int i = 0; i < size - 1; ++i)
	{
		printf("%d, ", arr[i]);
	}
	printf("%d \n\n", arr[size - 1]);
}

void createRandArr(int *arr, int size, int maxVal)
{
	for (int i = 0; i < size; ++i)
	{
		int rnd = (rand() / (float)(RAND_MAX)) * maxVal;
		arr[i] = rnd;
	}
}

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

void sortCPU(int *arr, int size)
{
	bool notSorted = true;
	int i = 0;
	int sorted = 1;
	while (sorted != (-size+1))
	{
		sorted = oddeven(arr, size, i % 2);
		sorted += oddeven(arr, size, (i+1) % 2);
		i += 2;
	}
}

__device__
int oddevenGPU(int *d_arr, int size, int oddeven, int blockSize)
{
	int sorted = 0;
	int start = threadIdx.x * blockSize + oddeven;
	int end = oddeven - blockSize + blockSize * threadIdx.x;
	for (int i = start; i < end; i += 2)
	{
		int minStep = d_arr[i] > d_arr[i + 1];
		int min = d_arr[i + minStep];
		int maxStep = d_arr[i] <= d_arr[i + 1];
		int max = d_arr[i + maxStep];

		d_arr[i] = min;
		d_arr[i + 1] = max;

		sorted += minStep - maxStep;
	}
	return sorted;
}

__global__
void addKernel(int *d_arr, int *d_size, int *d_blockSize)
{
	int size = *d_size;
	int blockSize = *d_blockSize;
	int nrThreads = size / blockSize;

	bool notSorted = true;
	int i = 0;
	int sorted = 1;
	while (sorted != (-size + 1))
	{
		sorted = 0;
		sorted += oddevenGPU(d_arr, size, i % 2, blockSize);
		__syncthreads();
		sorted += oddevenGPU(d_arr, size, (i + 1) % 2, blockSize);
		__syncthreads();
		i += 2;
	}
}

int main()
{
	srand((unsigned int)time(NULL));

	int size = 100;
	int setSize = 32;
	int *arr = (int*)malloc(size * sizeof(int));
	int *d_arr, *d_size, *d_blockSize;
	createRandArr(arr, size, size*2);

	printArr(arr, size);

	int set = size / 2;

	cudaMalloc(&d_arr, size * sizeof(int));
	cudaMalloc(&d_size, sizeof(int));
	cudaMalloc(&d_blockSize, sizeof(int));

	cudaMemcpy(d_arr, arr, size * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_size, &size, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_blockSize, &set, sizeof(int), cudaMemcpyHostToDevice);

	int nr = size / set;

	addKernel<<<1, 2>>>(d_arr, d_size, d_blockSize);
	cudaMemcpy(arr, d_arr, size * sizeof(int), cudaMemcpyDeviceToHost);

	printArr(arr, size);

	/*printArr(arr, size);
	sortCPU(arr, size);
	printArr(arr, size);*/

	system("pause");

	cudaFree(d_arr);
	cudaFree(d_size);
	free(arr);
	return 0;
}