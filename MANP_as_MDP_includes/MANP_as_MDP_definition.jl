# File with modules to use
include("modules_to_use.jl")

struct Page
   id :: Int64 
end

pages_collection = nothing

struct User1 
   id :: Int64
   userPreferencesFunction:: Any   # Recieve pages visited, current page shown
end;


struct Action1
   show_page :: Union{Page,Nothing}           # The page that is presented to the user
end

struct State1
    visited_pages :: Any                      # Didn't specified, because we need here immutable type.                                              # Supposed to be an immutable set
    if_terminal :: Bool
end 

mutable struct MdpStatistics
   current_user_path :: Array{Page,1} 
   nexts_per_page :: Array{Int64,1}
    leaves_per_page :: Array{Int64,1}
    total_pages_seen :: Int64
    users_number :: Int64
    pages_seen_per_user :: Array{Int64,1}
    page_fialures_num :: Int64
    
end

mutable struct ContentProducerMdp <: MDP{State1,Action1}
    pages :: Array{Page,1}
    current_user :: User1
    statistics :: MdpStatistics
    statistics_on :: Bool            # Whether the statistics should be collected
                                     # (Not neccessary for value iteration for example)
    
end



POMDPs.discount(mdp::ContentProducerMdp) = 1

POMDPs.initialstate(mdp::ContentProducerMdp)= SparseCat([State1(Tuple([]),false)],[1])

POMDPs.isterminal(mdp::ContentProducerMdp,s::State1)= return s.if_terminal

function POMDPs.transition(mdp::ContentProducerMdp,state::State1,act::Action1)

    pages_visited = state.visited_pages
    current_page = act.show_page
    
    # Attemp to show the same page twice
    if current_page in pages_visited
        return SparseCat([State1(Tuple([]),true)], [1.0]) 
    end
    
    # Attemp to take action in the terminal state
    if POMDPs.isterminal(mdp,state)
       return SparseCat([State1(Tuple([]),true)], [1.0]) 
    end
    
    # All the pages have been seen by the user
    if length(pages_visited) == length(mdp.pages) - 1
       return SparseCat([State1(Tuple([]),true)], [1.0])
    end
    
    # Getting user's leaving probability
    leaving_probab = mdp.current_user.userPreferencesFunction(collect(Page,pages_visited),current_page)
    
    # Creating the next state
    #
    if length(pages_visited) == 0
        new_page_visited = [current_page]
    else
        new_page_visited = push!(collect(pages_visited),current_page)
    end
    
    # Sort the pages in the newly created state by id
    sort!(new_page_visited,by=page->page.id,alg=InsertionSort)  # The array is almost sorted , that's why insertion sort
#     println("Previous state: $(state) Action: $(act)")
#     println([State1(Tuple(new_page_visited),false), State1(Tuple([]),true)],[1-leaving_probab,leaving_probab])
    # Return distribution object on possible states
    return SparseCat([State1(Tuple(new_page_visited),false), State1(Tuple([]),true)],[1-leaving_probab,leaving_probab])
end

function POMDPs.reward(mdp::ContentProducerMdp, state::State1, act::Action1, stateP::State1)
    
    # Collect statistics
    RecordStatistics(mdp, state, stateP, act)

    
    are_all_pages_seen = (POMDPs.isterminal(mdp,stateP) 
                        && length(state.visited_pages) >= (length(mdp.pages) - 1))
    
    # Attemp to show the same page twice
    if act.show_page in state.visited_pages
        return -100
    
    # The user pressed "next"     
    elseif !POMDPs.isterminal(mdp, stateP) ||  are_all_pages_seen
        return 1
    
    # The user pressed "leave"
    else
        return 0
    end

end

include("functions.jl");

