struct RandSolver <: Solver
end

mutable struct RandPolicy <: Policy
	pages_shown :: Array{Page,1}
   actions ::  Array{Action_simple,1}
end



function POMDPs.solve(solver:: RandSolver, mdp :: ContentProducerMdp1)
    
    acts = [action for action in POMDPs.actions(mdp) if action.show_page !== nothing]
    
    return RandPolicy([],acts)
end

function POMDPs.action(policy:: RandPolicy, state:: State_simple)
    pages = [action.show_page for action in policy.actions]
    remaining_pages = setdiff(Set(pages),policy.pages_shown)
    
	 if length(remaining_pages) == 0
        policy.pages_shown = Page[]            
        return Action_simple(nothing)
    end 
	Rand_action = Action_simple(rand(remaining_pages))
	push!(policy.pages_shown, Rand_action.show_page)
    return Rand_action
end


