try
    using Pkg
    using POMDPs            # POMDPs.jl interface
    using POMDPModelTools   # POMDPModelTools has tools that help build the MDP definition
    using POMDPPolicies
    using POMDPSimulators
	using Distributions

catch  LoadError
    Pkg.add("POMDPs")
    Pkg.add("POMDPModelTools")
    Pkg.add("POMDPPolicies")
    Pkg.add("POMDPSimulators")
    Pkg.add("Combinatorics")
	Pkg.add("Distributions")
	
    using POMDPs
    using POMDPModelTools
    using POMDPPolicies
    using POMDPSimulators
	using Distributions


end;