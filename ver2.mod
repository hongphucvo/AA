/*********************************************
 * OPL 22.1.0.0 Model
 * Author: hongphucvo
 * Creation Date: Apr 21, 2022 at 8:21:50 PM
*********************************************/

//General n
int numJob = 6;
int numMachine = 2;
int numPeriodTime = 5;
int numBreakTime = 4;

float INF = 100000;

range rangeProcessTimeJob = 1 .. numJob;
range rangeMachine = 1 .. numMachine;
range rangePeriodTime = 1 .. numPeriodTime;
range rangeBreakTime = 1 .. numBreakTime;

//window
tuple availableTime {
  int Machine;
  int PeriodTime;
}
{availableTime} machineTime = {< 1, 1 >, < 1, 2 >, < 1, 3 >, < 1, 4 >, < 2, 1 >,
   < 2, 2 >, < 2, 3 >, < 2, 4 >, < 2, 5 >};

tuple breakTime {
  int Machine;
  int BreakTime;
}
{breakTime} machineBreakTime = {< 1, 1 >, < 1, 2 >, < 1, 3 >, < 2, 1 >, < 2,2 >, < 2, 3 >, < 2, 4 >};

tuple ite {
  int processTimeJob1;
  int processTimeJob2;
  //  i1,i2
}

//sequence
{ite} processTimeJobOverlap = {< 1, 2 >, < 2, 3 >, < 3, 4 >, < 4, 5 >, < 5, 6 >,
   < 6, 7 >};

//no sequence : job 1 lam trc job 2 lam sau thi <1,2> permutation
//{i}processTimeJobOverlap={<1,2>,<2,1>,<1,3>,<1,4>,<1,5>,<1,6>,<1,7>,<2,3><2,4>,<2,5>,<2,6>,...};



// 1 if overlap else 0
dvar boolean overlap[rangeProcessTimeJob][rangeProcessTimeJob];



float J[rangeProcessTimeJob] =[6, 7, 8, 5, 10, 4];
float machineAvaiTimeStart[machineTime] =[0, 7, 12, 20, 0, 5, 11, 18, 25];
float machineAvaiTimeEnd[machineTime] =[7, 12, 20, INF, 5, 11, 18, 25, INF];
float machineBrkTime[machineBreakTime] =[7, 12, 20, 5, 11, 18, 25];


float split = 3;

//execute INITIALIZE {
//var nb1 = 0;
//}



// determined variabl: multi dimension
dvar boolean x[rangeProcessTimeJob][machineTime];
dvar float y[rangeProcessTimeJob][machineTime];
dvar float s[rangeProcessTimeJob][machineTime];
dvar boolean z[rangeProcessTimeJob][rangeMachine];
dvar boolean v[processTimeJobOverlap][machineTime];



// trung gian
dvar float c[rangeProcessTimeJob][machineTime];
dvar float Ci[rangeProcessTimeJob][machineTime];
dvar float Cmax;


minimize
  Cmax;

subject to{
  forall ( i in rangeProcessTimeJob ) {
    J[i] == sum ( <j,t> in machineTime ) y[i][<j,t>] ;
    // J is p
  }
  forall(<j,t> in machineTime){
//TODO find i   
//	sum(i in rangeProcessTimeJob) machineAvaiTimeStart[<j,t>] <= y[i][<j,t>] <= machineAvaiTimeEnd[<j,t>];
//	sum(i in rangeProcessTimeJob) machineAvaiTimeStart[<j,t>] <= y[t][<j,t>] <= machineAvaiTimeEnd[<j,t>];

   machineAvaiTimeEnd[<j,t>]- machineAvaiTimeStart[<j,t>]>=sum(i in rangeProcessTimeJob)y[i][<j,t>];
      } 
  
  forall ( i in rangeProcessTimeJob, <j,t> in machineTime ) {
//    TODO: find x
// split min
    split * x[i,<j,t>] <= y[i][<j,t>] && y[i][<j,t>] <= J[i] * x[i][<j,t>];
  }
  
  forall(i in rangeProcessTimeJob,<j,t> in machineTime  ){
    machineBrkTime[<j,t>] * x [i][<j,t>] <= s [i][<j,t>] && s [i][<j,t>]   <= machineBrkTime[<j,t+1>] * x[i][<j,t>]-y[i][<j,t>]; 
  }
  
  forall(i1,i2 in rangeProcessTimeJob, <j,t> in machineTime){
    if(i1!=i2){
    c[i1][<j,t>]<= s[i2][<j,t>] &&
    c[i2][<j,t>]<=s[i1][<j,t>];
    }
  }
  
  forall( i in rangeProcessTimeJob,<j,t> in machineTime){
    0!=sum(<j,t> in machineTime) x[i][<j,t>] || z[i,j] != 0;
  }
  
  forall (i in rangeProcessTimeJob){
    1 == sum(<j,t> in machineTime) z[i,j];
  }
}






