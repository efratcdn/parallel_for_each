  Usage example of the Parallel For Each

  
  specman -c 'load parallel_for_each/e_util_parallel_for_each_ex.e; test'

  
  The env unit contains a list of agent. 
  
  It run in parallel the TCM my_method() of the agents.

  
<'

unit agent {      
  
    // implement some TCM; it doesn't' really matter what it is doing, 
    // the important thing is that all TCMs of all agents will run in parallel;
    my_method() @sys.any is {
        message(LOW, "my_method() being called");
        var wait_cycles : int;
        gen wait_cycles keeping {it in [10..100]};
        wait [wait_cycles] * cycle;
        message(LOW, "my_method() ends");
    };


    //
    // Wrapping the method:
    //
    my_method_wrap (agent : agent) @sys.any is {
        my_method_increase();
        agent.my_method();
        my_method_decrease();
    };

    // static field, so that there is one counter for all agent instances
    static my_method_execution_ctr : int = 0;
    
    my_method_increase() is {
        my_method_execution_ctr += 1;
        assert my_method_execution_ctr >= 0;
    };
    my_method_decrease() is {
        my_method_execution_ctr -= 1;
        assert my_method_execution_ctr >= 0;
    };
    
    my_method_get_ctr() : int is {
        result = my_method_execution_ctr;
    };
};

unit env {
    agents : list of agent is instance;
    keep agents.size() is in [3..7];
    
    scenario() @sys.any is {
        raise_objection(TEST_DONE);        
        
        // 
        // Run in parallel the TCM my_method() of all agents:
        //
        
        for each in agents {
            start it.my_method_wrap(it);
        };
        wait true(agent::my_method_execution_ctr == 0);
        
        out();
        message(LOW, "All agents are done, continue running\n");
        
       
        wait cycle;
        drop_objection(TEST_DONE);
    };
    run() is also {
        start scenario();
    };
    
   
    
};

extend sys {
    env : env is instance;
};

'>


