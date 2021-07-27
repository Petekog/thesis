#
function CreatePages(number :: Int64)
    global pages_collection = [Page(id) for id in 1:number]
end

function RecordStatistics(mdp::ContentProducerMdp1, state::State_simple,next_state::State_simple,act::Action_simple)
    
    if ! mdp.statistics_on 
       return 
    end
    
	
	statistics = mdp.statistics
	current_page = act.show_page
	
	if current_page === nothing
		statistics.users_number += 1
        push!(statistics.pages_seen_per_user, length(statistics.current_user_path) )
		
		println("The agent stopped showing the pages.")
		println("Summary: \n Pages seen: $(statistics.current_user_path) \n Number of pages seen: $(length(statistics.current_user_path))")
		
		
        statistics.current_user_path = Page[]
     
		return
	end
	
    println("The agent showed page : $(act.show_page)")
    
    page_id =  current_page.id  
    
    if !POMDPs.isterminal(mdp,next_state)
        push!(statistics.current_user_path, current_page)
        statistics.total_pages_seen += 1
        statistics.nexts_per_page[page_id] +=1
        
    else 
        push!(statistics.current_user_path, current_page)
        statistics.leaves_per_page[page_id] +=1
        statistics.users_number += 1
        push!(statistics.pages_seen_per_user, length(statistics.current_user_path) )
        
        statistics.total_pages_seen += 1
		println("The user leaved.")
		println("\033[1m\033[4mSummary \033[0m : \n Pages seen: $(statistics.current_user_path) \n Number of pages seen: $(length(statistics.current_user_path))")
		
		statistics.current_user_path = Page[]
        
    end
end

#
function InitStatistics1(pages_number :: Int64)
    nexts_per_page = zeros(Int64,pages_number)
    leaves_per_page = zeros(Int64,pages_number)
    
    return MdpStatistics1([],nexts_per_page,leaves_per_page,0,0,[],0)
end



function userPreferencesCreate(pages :: Array{Page,1}, page_probab :: Array{Float64,1}) 
    page_prob_dict = Dict(pages .=> page_probab)
    
   function userPreferences(curr_page :: Page)
       return  page_prob_dict[curr_page]
    end    
end;


function running_average(stat::MdpStatistics1)
    sums = 0
    averages = Float64[]
    
    for i in 1:length(stat.pages_seen_per_user)
        sums += stat.pages_seen_per_user[i]
        push!(averages, sums/i)
    end
    return averages
end

#==========================================================================================#

function POMDPs.states(mdp::ContentProducerMdp1)
    
    return [State_simple(false), State_simple(true)]
end

function POMDPs.actions(mdp::ContentProducerMdp1)
    actions = [Action_simple(page) for page in mdp.pages]
	push!(actions,Action_simple(nothing))	
	return actions
end

function POMDPs.stateindex(mdp::ContentProducerMdp1, state::State_simple)
    if POMDPs.isterminal(state)
        return 2
    else
        return 1
    end
end

function POMDPs.actionindex(mdp::ContentProducerMdp1,act::Action_simple)
   return act.show_page.id
end



