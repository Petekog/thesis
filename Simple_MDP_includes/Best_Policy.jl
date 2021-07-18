struct BestSolver <: Solver
end

mutable struct BestPolicy <: Policy
	pages_shown :: Array{Page,1}
   sorted_actions ::  Array{Action_simple,1}
end



function POMDPs.solve(solver:: BestSolver, mdp :: ContentProducerMdp1)
    action_prob_pairs = []
    for action in POMDPs.actions(mdp)
	if action.show_page === nothing
           continue 
        end
       prob = mdp.current_user.userPreferencesFunction(action.show_page)
        push!(action_prob_pairs,(action,prob))
    end
    
    sort!(action_prob_pairs,by=x-> x[2])
    
    return BestPolicy([],[action_prob[1] for action_prob in action_prob_pairs])
end

function POMDPs.action(policy:: BestPolicy, state:: State_simple)
    visited_pages = Set(policy.pages_shown)
    sorted_pages = [action.show_page for action in policy.sorted_actions]
    best_action_index = findfirst(x -> !(x in visited_pages), sorted_pages) 
    
	 if best_action_index === nothing
        policy.pages_shown = Page[]            
        return Action_simple(nothing)
    end 
	best_action = policy.sorted_actions[best_action_index]
	push!(policy.pages_shown, best_action.show_page)
    return best_action
end


