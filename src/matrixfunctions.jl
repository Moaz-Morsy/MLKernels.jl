#===================================================================================================
  Matrix Functions
===================================================================================================#

#==========================================================================
  Auxiliary Functions
==========================================================================#

description_matrix_size(A::Matrix) = string(size(A,1), "×", size(A,2))

# Symmetrize the lower half of matrix S using the upper half of S
function syml!(S::Matrix)
    (p = size(S,1)) == size(S,2) || throw(ArgumentError("S ∈ ℝ$(p)×$(size(S, 2)) must be square"))
    if p > 1 
        @inbounds for j = 1:(p - 1), i = (j + 1):p 
            S[i, j] = S[j, i]
        end
    end
    S
end
syml(S::Matrix) = syml!(copy(S))

# Symmetrize the upper off-diagonal of matrix S using the lower half of S
function symu!(S::Matrix)
    (p = size(S,1)) == size(S,2) || throw(ArgumentError("S ∈ ℝ$(p)×$(size(S, 2)) must be square"))
    if p > 1 
        @inbounds for j = 2:p, i = 1:(j-1)
            S[i,j] = S[j,i]
        end
    end
    S
end
symu(S::Matrix) = symu!(copy(S))

# Return vector of dot products for each row of A
function dot_rows{T<:FloatingPoint}(A::Matrix{T})
    n, m = size(A)
    aᵀa = zeros(T, n)
    @inbounds for j = 1:m, i = 1:n
        aᵀa[i] += A[i,j] * A[i,j]
    end
    aᵀa
end

# Return vector of dot products for each row of A
function dot_rows{T<:FloatingPoint}(A::Matrix{T}, w::Array{T})
    n, m = size(A)
    length(w) == m || throw(ArgumentError("w must have the same length as A's rows."))
    aᵀa = zeros(T, n)
    @inbounds for j = 1:m, i = 1:n
        aᵀa[i] += A[i,j] * A[i,j] * w[j]
    end
    aᵀa
end

# Return vector of dot products for each column of A
function dot_columns{T<:FloatingPoint}(A::Matrix{T})
    n, m = size(A)
    aᵀa = zeros(T, m)
    @inbounds for j = 1:m, i = 1:n
        aᵀa[j] += A[i,j] * A[i,j]
    end
    aᵀa
end

# Return vector of dot products for each column of A
function dot_columns{T<:FloatingPoint}(A::Matrix{T}, w::Array{T})
    n, m = size(A)
    length(w) == n || throw(ArgumentError("w must have the same length as A's rows."))
    aᵀa = zeros(T, m)
    @inbounds for j = 1:m, i = 1:n
        aᵀa[j] += A[i,j] * A[i,j] * w[i]
    end
    aᵀa
end

# Add array z to each row in X, overwrites and returns X
function row_add!{T<:FloatingPoint}(X::Matrix{T}, z::Array{T})
    n, p = size(X)
    p == length(z) || throw(ArgumentError("Dimensions do not conform"))
    @inbounds for j = 1:p
        for i = 1:n
            X[i,j] += z[j]
        end
    end
    X
end

# Add array z to each column in X, overwrites and returns X
function col_add!{T<:FloatingPoint}(X::Matrix{T}, z::Array{T})
    n, p = size(X)
    p == length(z) || throw(ArgumentError("Dimensions do not conform"))
    @inbounds for j = 1:p
        for i = 1:n
            X[i,j] += z[i]
        end
    end
    X
end

# Subtract array z from each row in X, overwrites and returns X
function row_sub!{T<:FloatingPoint}(X::Matrix{T}, z::Array{T})
    n, p = size(X)
    p == length(z) || throw(ArgumentError("Dimensions do not conform"))
    @inbounds for j = 1:p
        for i = 1:n
            X[i,j] -= z[j]
        end
    end
    X
end

# Subtract array z from each column in X, overwrites and returns X
function col_sub!{T<:FloatingPoint}(X::Matrix{T}, z::Array{T})
    n, p = size(X)
    p == length(z) || throw(ArgumentError("Dimensions do not conform"))
    @inbounds for j = 1:p
        for i = 1:n
            X[i,j] -= z[i]
        end
    end
    X
end


#==========================================================================
  Matrix Operations
==========================================================================#

# Overwrite A with the hadamard product of A and B. Returns A
function hadamard!{T<:FloatingPoint}(A::Array{T}, B::Array{T})
    length(A) == length(B) || error("A and B must be of the same length.")
    @inbounds for i = 1:length(A)
        A[i] *= B[i]
    end
    A
end

# Overwrite A with the hadamard product of A and B. Returns A
function hadamard!{T<:FloatingPoint}(A::Matrix{T}, B::Matrix{T}, is_upper::Bool, sym::Bool = true)
    n = size(A,1)
    if !(n == size(A,2) == size(B,1) == size(B,2))
        throw(ArgumentError("A and B must be square and of same order."))
    end
    @inbounds for j = 1:n
        for i = is_upper ? (1:j) : (j:n)
            A[i,j] *= B[i,j]
        end 
    end
    sym ? (is_upper ? syml!(A) : symu!(A)) : A
end

