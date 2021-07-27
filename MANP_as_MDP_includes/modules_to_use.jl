#
try
    using Pkg
    using POMDPs            # POMDPs.jl interface
    using POMDPModelTools   # POMDPModelTools has tools that help build the MDP definition
    using POMDPPolicies
    using POMDPSimulators
    using Combinatorics
    using DiscreteValueIteration
    using StatsPlots
    using Plots
    using Distributions

catch  LoadError
    Pkg.add("POMDPs")
    Pkg.add("POMDPModelTools")
    Pkg.add("POMDPPolicies")
    Pkg.add("POMDPSimulators")
    Pkg.add("Combinatorics")
    Pkg.add("DiscreteValueIteration")
    Pkg.add("StatsPlots")
    Pkg.add("Plots")
    Pkg.add("Distributions")
    using DiscreteValueIteration
    using POMDPs
    using POMDPModelTools
    using POMDPPolicies
    using POMDPSimulators
    using Combinatorics
    using StatsPlots
    using Plots
    using Distributions

end;