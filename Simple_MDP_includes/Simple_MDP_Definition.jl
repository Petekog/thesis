# File with modules to use
include("modules_to_use.jl")

struct Page
   id :: Int64 
end

pages_collection = nothing

struct User_simple 
   id :: Int64
   userPreferencesFunction:: Any   # Recieve pages visited, current page shown
end;



struct Action_simple
   show_page :: Union{Page,Nothing}           # The page that is presented to the user
end

struct State_simple                             
    if_terminal :: Bool
end 

mutable struct MdpStatistics1
    current_user_path :: Array{Page,1} 
    nexts_per_page :: Array{Int64,1}
    leaves_per_page :: Array{Int64,1}
    total_pages_seen :: Int64
    users_number :: Int64
    pages_seen_per_user :: Array{Int64,1}
    page_fialures_num :: Int64
    
end

mutable struct ContentProducerMdp1 <: MDP{State_simple,Action_simple}
    pages :: Array{Page,1}
    current_user :: User_simple
    statistics :: MdpStatistics1
    statistics_on :: Bool            # Whether the statistics should be collected
                                     # (Not neccessary for value iteration for example)
    
end


POMDPs.discount(mdp::ContentProducerMdp1) = 1

POMDPs.initialstate(mdp::ContentProducerMdp1)= SparseCat([State_simple(false)],[1])

POMDPs.isterminal(mdp::ContentProducerMdp1,s::State_simple)= return s.if_terminal

function POMDPs.transition(mdp::ContentProducerMdp1,state::State_simple,act::Action_simple)

    current_page = act.show_page   
    
    # Attemp to take action in the terminal state
    if POMDPs.isterminal(mdp,state)
       return SparseCat([State_simple(true)], [1.0]) 
    end
    
    # Stop showing pages to the user 
    if current_page === nothing
        return SparseCat([State_simple(true)], [1.0]) 
    end
    
    # Getting user's leaving probability
    leaving_probab = mdp.current_user.userPreferencesFunction(current_page)
    
    # Return distribution object on possible states
    return SparseCat([State_simple(false), State_simple(true)],[1-leaving_probab,leaving_probab])
end


function POMDPs.reward(mdp::ContentProducerMdp1, state::State_simple, act::Action_simple, stateP::State_simple)
    
    # Collect statistics
    RecordStatistics(mdp, state, stateP, act)
    # The user pressed "next"     
    if !POMDPs.isterminal(mdp, stateP)    
        return 1
    # The user pressed "leave"
    else
        return 0
    end

end


include("functions.jl")

#=
pages_number = 10

pages1 = CreatePages(pages_number)

# Creating user preferences function
User_simple1 = User_simple(1,
    userPreferencesCreate(pages1, collect(1:-(1/pages_number):1/pages_number))
             );

# MDP and statistics initialization 
statistics1 = InitStatistics1(length(pages1))
mdp1 = ContentProducerMdp1(pages1, User_simple1, statistics1, true);

# We select a random policy that is provided by POMDPs package to perform an initial testing for the model.
policy1 = RandomPolicy(mdp1);

# The most simple POMDPs simulator.
rs = RolloutSimulator();

for _ in 1:5
    println("\n\n=========== Simulation starts ===============")
    r = simulate(rs,mdp1,policy1)
    println("\033[1m Reward \033[0m : $(r)")
end
=#
