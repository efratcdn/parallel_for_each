# parallel_for_each
* Title       : Parallel For Each  
* Version     : 1.0
* Requires    : Specman {15.20...}
* Modified    : November 2017
* Description :

[ More e code examples in https://github.com/efratcdn/spmn-e-utils ]


The Requirement:

   Need a feature that is a combination of  "for each in list" and "all of".

   Run in parallel a TCM of a list of units.

   The use model:

     There is a list of unknown length of units, and need to run in parallel
     a method of this unit. The run should be of fork-join nature - the 
     calling method will continue only after all executions are done.

   A "for each in..." can be used to run the methods in sequential, but not 
   in parallel 

     for each in agents {
        it.my_method();
     };


   A "all of ..." can be used to run in parallel, but only when the size of
   the list is known.



A Solution:

   Implement a wrapper to the method that is to be called. The wrapper:

     1) increases a counter
     2) calls the method
     3) decreases the counter
     4) if the counter reaches 0 - a static event is emitted

   The calling method start the wrapper of all the units in the list, and 
   waits for the event, indicating that all methods execution ended.
  
   One difference if this implementation from 'all of', is that when using 'all of' 
   when the calling thread is terminated all the sub threads are terminated.
   With this solution, the sub threads are started (and not called), so even if 
   the calling thread is terminated - they continue running. 

   See an example for such a wrapper in e_util_parallel_for_each_manual_code.e


       specman -c 'load e_util_parallel_for_each_manual_code.e;test'



A Utility:

   Instead of implementing the wrapper, you can also use the macros in the file
   e_util_parallel_for_each.e.
   This files contains two macros implementing the described methodology.

   Usage:
 
        1) Wrap the method that is to be called, using this macro:
              
              wrap_for_parallel <method name>
               
           For example
               
              wrap_for_parallel my_method;
             
 
	2) Call the method, using this macro
              
              for_each_in_parallel <list field name> <list type> <method name> 
               
           For example 
              
             for_each_in_parallel agents agent my_method;


   See usage example e_util_parallel_for_each_usage_ex.e 
              
        
      specman -c 'load parallel_for_each/e_util_parallel_for_each_usage_ex.e; test'


   These macros are a suggestion, you can use them as is, or extend to provide 
   additional capabilities.
   
   For example - to support passing parameters to the called method.
