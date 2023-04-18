using System;
using System.Data;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PIMSim.Configs;
using PIMSim.Memory;
using PIMSim.General;
using PIMSim.Procs;

namespace PIMSim
{
    class Program
    {
        public static bool graceFulExit = false;
        /// <summary>
        /// When application is going to exit, close file handles.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        static void CurrentDomain_ProcessExit(object sender, EventArgs e)
        {
            try { Config.fs.Close(); } catch { } // god this code makes me wanna vomit
            try { Config.sw.Close(); } catch { } // god this code makes me wanna vomit
            if (!graceFulExit) {
                Console.WriteLine("Press any key to exit.");
                Console.ReadKey();
            }
        }
        public static PIMSimulator pimsim;
        static void Main(string[] args)
        {
            AppDomain.CurrentDomain.ProcessExit += new EventHandler(CurrentDomain_ProcessExit);
            pimsim = new PIMSimulator(args);
            pimsim.run();
            pimsim.PrintStatus();
            Console.WriteLine("Press any key to continue.");
            Console.ReadKey();
            graceFulExit = true;
        }
    }
}
