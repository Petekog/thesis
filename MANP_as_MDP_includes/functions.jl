


function POMDPs.stateindex(mdp::ContentProducerMdp, state::State1)
    indeces = zeros(Int64,length(mdp.pages))
    i = 1
    visited_pages = state.visited_pages
    for j in 1:length(mdp.pages)
        if i > length(visited_pages)
           break 
        end
        if mdp.pages[j] == visited_pages[i]
           
            indeces[j] = 1
            i+=1
        end
    end
    
    if POMDPs.isterminal(mdp,state)
        return  BitArrToInt(ones(Int64,length(mdp.pages))) + 1
    end
    return BitArrToInt(indeces)+ 1
end

function POMDPs.actionindex(mdp::ContentProducerMdp,act::Action1)
   return act.show_page.id
end

function POMDPs.states(mdp::ContentProducerMdp)
    pages_superset = collect(setdiff(powerset(mdp.pages),[mdp.pages]))             # We assume that the function preserves the order (not in docs)
    states = [State1(Tuple(pages),false) for pages in pages_superset]  
    push!(states, State1(Tuple([]),true))
    return states
end

function POMDPs.actions(mdp::ContentProducerMdp)
    actions = [Action1(page) for page in mdp.pages]  
end

#
function CreatePages(number :: Int64)
    global pages_collection = [Page(id) for id in 1:number]
end

function BitArrToInt(arr)
    return sum(arr .* (2 .^ collect(0:length(arr)-1)))
    end;

#
function InitStatistics(pages_number :: Int64)
    nexts_per_page = zeros(Int64,pages_number)
    leaves_per_page = zeros(Int64,pages_number)
    
    return MdpStatistics([],nexts_per_page,leaves_per_page,0,0,[],0)
end

function RecordStatistics(mdp::ContentProducerMdp, state::State1,next_state::State1,act::Action1)
    
    if ! mdp.statistics_on 
       return 
    end
    
    statistics = mdp.statistics
    current_page = act.show_page
    page_id =  current_page.id  
    
    is_all_pages_seen = (POMDPs.isterminal(mdp,next_state) 
                        && length(state.visited_pages) >= (length(mdp.pages) - 1))
     println("The agent showed page : $(act.show_page)")
	 
    if act.show_page in state.visited_pages
        statistics.page_fialures_num += 1
        statistics.users_number += 1
        push!(statistics.pages_seen_per_user, length(statistics.current_user_path) )
        statistics.current_user_path = Page[]
        
    elseif !POMDPs.isterminal(mdp,next_state)
        push!(statistics.current_user_path, current_page)
        statistics.nexts_per_page[page_id] +=1
        statistics.total_pages_seen += 1
        
    else 
        push!(statistics.current_user_path, current_page)
                if is_all_pages_seen
            statistics.nexts_per_page[page_id] +=1
        else
            statistics.leaves_per_page[page_id] +=1
        end
        statistics.users_number += 1
        push!(statistics.pages_seen_per_user, length(statistics.current_user_path) )
       println("The user leaved.")
		println("\033[1m\033[4mSummary \033[0m : \n Pages seen: $(statistics.current_user_path) \n Number of pages seen: $(length(statistics.current_user_path))")
		
	   statistics.current_user_path = Page[]
        statistics.total_pages_seen += 1
        
    end
    #println(statistics)   
end;


function running_average(stat::MdpStatistics)
    sums = 0
    averages = Float64[]
    
    for i in 1:length(stat.pages_seen_per_user)
        sums += stat.pages_seen_per_user[i]
        push!(averages, sums/i)
    end
    return averages
end

function userPreferencesCreate(pages :: Array{Page,1}, page_probab :: Array{Float64,1}) 
    page_prob_dict = Dict(pages .=> page_probab)
    
   function userPreferences(pages :: Array{Page,1}, curr_page :: Page)
       return  page_prob_dict[curr_page]
    end    
end;
