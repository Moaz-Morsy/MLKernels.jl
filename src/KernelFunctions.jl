#===================================================================================================
  Kernel Functions Module
===================================================================================================#

module KernelFunctions

import Base: show, call, exp, isposdef

export
    # Functions
    arguments,
    description,
    isposdef_kernel,
    is_euclidean_distance,
    is_scalar_product,
    kernel_function,
    scalar_kernel_function,
    vectorized_kernel_function,
    vectorized_kernel_function!,
    # Types
    Kernel,
        SimpleKernel,
            StandardKernel,
                PointwiseProductKernel,
                GenericKernel,
                StationaryKernel,
	                GaussianKernel,
	                LaplacianKernel,
            	    RationalQuadraticKernel,
            	    MultiQuadraticKernel,
            	    InverseMultiQuadraticKernel,
            	    PowerKernel,
            	    LogKernel,
                NonStationaryKernel,
	                LinearKernel,
	                PolynomialKernel,
            	    SigmoidKernel,
            TransformedKernel,
                ExponentialKernel,
                ExponentiatedKernel,
            ScalableKernel,
            ScaledKernel,
        CompositeKernel,
            KernelProduct,
            KernelSum




include("Kernels.jl")

end # KernelFunctions