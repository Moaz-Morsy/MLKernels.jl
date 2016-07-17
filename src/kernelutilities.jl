#===================================================================================================
  Kernel Standardization
===================================================================================================#

#=
type KernelStandardizer{T<:AbstractFloat}
    normalize::Bool
    center::Bool
    kappa::Vector{T}
    k::T
end

KernelStandardizer{T<:AbstractFloat}(X::Matrix{T}

centerkernelmatrix!(K::AbstractMatrix{T}, diag_K::Vector{T}, 
=#

#=
function rankedapproximation!{T<:AbstractFloat}(W::Matrix{T}, D::Vector{T}, U::Matrix{T}, k::Integer)
    n = size(W,1)
    for j = 1:n, i = 1:j
        s = zero(T)
        @simd for l = 1:k
            @inbounds Uik = U[i,k]
            @inbounds Ujk = U[j,k]
            tmp = Uik * Ujk
            s += D[k]*tmp
        end
        W[i,j] = s
    end
    W
end
=#

#eps(real(float(one(eltype(M)))))*maximum(size(A))

#===================================================================================================
  Nystrom Approximation
===================================================================================================#

function srswr(n::Integer, r::AbstractFloat)
    0 < r <= 1 || error("Sample rate must be between 0 and 1")
    ns = Int64(trunc(n*r))
    return Int64[Int64(trunc(u*n +1)) for u in rand(ns)]
end

function nystrom{T<:AbstractFloat}(
        σ::MemoryOrder,
        f::RealFunction{T},
        X::Matrix{T},
        s::Vector{Int64}
    )
    n = length(s)
    Xs = σ == Val{:row} ? X[s,:] : X[:,s]
    C = kernelmatrix(σ, f, Xs, X)
    tol = eps(T)*n
    VDVᵀ = eigfact!(Symmetric(C[:,s]))
    D = VDVᵀ.values
    for i in eachindex(D)
        @inbounds D[i] = abs(D[i]) <= tol ? zero(T) : 1/sqrt(D[i])
    end
    V = VDVᵀ.vectors
    DV = scale!(V,D)
    W = LinAlg.syrk_wrapper!(Array(T,n,n), 'N', DV)
    return (LinAlg.copytri!(W, 'U'), C)
end

function nystrom{T<:AbstractFloat}(
        σ::MemoryOrder,
        f::RealFunction{T},
        X::Matrix{T},
        r::AbstractFloat = 0.15
    )
    n = size(X, σ == Val{:row} ? 1 : 2)
    s = srswr(n, r)
    nystrom(σ, f, X, s)
end

immutable NystromFact{T<:AbstractFloat}
    W::Matrix{T}
    C::Matrix{T}
end

function NystromFact{T<:AbstractFloat}(
        σ::MemoryOrder,
        f::RealFunction{T},
        X::Matrix{T},
        r::AbstractFloat = 0.15
    )
    W, C = nystrom(σ, f, X, r)
    NystromFact{T}(W, C)
end

function NystromFact{T<:AbstractFloat}(
        f::RealFunction{T},
        X::Matrix{T},
        r::AbstractFloat = 0.15
    )
    NystromFact(Val{:row}, f, X, r)
end

function pairwisematrix{T<:AbstractFloat}(CᵀWC::NystromFact{T})
    W = CᵀWC.W
    C = CᵀWC.C
    At_mul_B(C,W)*C
end
