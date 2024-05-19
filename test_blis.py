import numpy as np
import blis

# Define the dimensions of the matrices
nO, nI, nN = 3, 3, 3

# Create random matrices A and B
A = np.random.rand(nN, nI).astype(np.float32)
B = np.random.rand(nI, nO).astype(np.float32)

# Initialize the result matrix C
C = np.zeros((nN, nO), dtype=np.float32)

# Perform matrix multiplication using BLIS
blis.gemm(blis.NO_TRANSPOSE, blis.NO_TRANSPOSE, nO, nI, nN, 1.0, A, nI, 1, B, nO, 1, 1.0, C, nO, 1)

# Print the result
print("Matrix A:")
print(A)
print("\nMatrix B:")
print(B)
print("\nResulting Matrix C (A * B):")
print(C)
