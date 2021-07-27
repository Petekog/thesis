struct BestSolver <: Solver
end

mutable struct BestPolicy <: Policy
   sorted_actions ::  Array{Action1,1}
end



function POMDPs.solve(solver:: BestSolver, mdp :: ContentProducerMdp)
    action_prob_pairs = []
    for action in POMDPs.actions(mdp)
	if action.show_page === nothing
           continue 
        end
       prob = mdp.current_user.userPreferencesFunction(Page[],action.show_page)
        push!(action_prob_pairs,(action,prob))
    end
    
    sort!(action_prob_pairs,by=x-> x[2])
    
    return BestPolicy([action_prob[1] for action_prob in action_prob_pairs])
end

function POMDPs.action(policy:: BestPolicy, state:: State1)
    visited_pages = Set(state.visited_pages)
    sorted_pages = [action.show_page for action in policy.sorted_actions]
    best_action_index = findfirst(x -> !(x in visited_pages), sorted_pages) 
    
	 if best_action_index === nothing           
        return Action1(nothing)
    end 
	best_action = policy.sorted_actions[best_action_index]
    return best_action
end


