struct RandSolver <: Solver
end

mutable struct RandPolicy <: Policy
	pages_shown :: Array{Page,1}
   actions ::  Array{Action1,1}
end



function POMDPs.solve(solver:: RandSolver, mdp :: ContentProducerMdp)
    
    acts = [action for action in POMDPs.actions(mdp) if action.show_page !== nothing]
    
    return RandPolicy([],acts)
end

function POMDPs.action(policy:: RandPolicy, state:: State1)
    pages = [action.show_page for action in policy.actions]
    remaining_pages = setdiff(Set(pages), state.visited_pages)
    
	if length(remaining_pages) == 0
        policy.pages_shown = Page[]            
        return Action1(nothing)
    end 
	Rand_action = Action1(rand(remaining_pages))
    return Rand_action
end


