import torch
import time

# Check if CUDA is available
if torch.cuda.is_available():
    print("CUDA is available. Device:", torch.cuda.get_device_name(0))
else:
    print("CUDA is not available.")
    exit()

print(torch.__version__)

# Set device to CUDA
device = torch.device("cuda")

# Create random matrices
matrix_size = 1024
A = torch.randn(matrix_size, matrix_size, device=device, dtype=torch.float16)
B = torch.randn(matrix_size, matrix_size, device=device, dtype=torch.float16)

# Warm-up
for _ in range(10):
    C = torch.matmul(A, B)

# Measure performance
start_time = time.time()
C = torch.matmul(A, B)
end_time = time.time()

print(f"Matrix multiplication using Tensor Cores took {end_time - start_time:.6f} seconds")

# Verify the result
C_cpu = C.cpu().numpy()
print("Result verification (sum of elements):", C_cpu.sum())