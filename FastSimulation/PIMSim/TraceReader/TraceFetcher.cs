#region Reference
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using PIMSim.Configs;
using PIMSim.General;
using PIMSim.Statistics;
using PIMSim.General.Ports;
using PIMSim.General.Protocols;
#endregion

namespace PIMSim.TraceReader
{
    /// <summary>
    /// TraceFetcher Defination
    /// </summary>
    public class TraceFetcher :SimulatorObj
    {
        #region Private Variables

        private FileReader reader;

        /// <summary>
        /// Trace file folder path.
        /// </summary>
        private string path = Config.trace_path;

        #endregion
        public TraceFetcherMasterPorts port;
        #region Public Methods

        public Input get_req(int pid_)
        {
            return reader.get_req(pid_);
        }


        public TraceFetcher()
        {
            name = "TraceFetcher";

            if(Config.trace_type== Trace_Type.Detailed)
            {
                // reader = ClassActivition.CreateInstance<FileReader>("PIMSim.TraceReader.DetailedTxtReader");
                reader = new DetailedTxtReader();
             } else if(Config.trace_type == Trace_Type.PC) {
                reader = new PCTxtReader();
            } else {
                DEBUG.Error("Undefined TraceFetcher Type");
                Environment.Exit(2);
            }

            port = new TraceFetcherMasterPorts("TraceFetcher Data Port", PortManager.Allocate());
            port.owner = this;
        }
        public void ServeBuffer()
        {
            if (port.buffer.Count() > 0)
            {
                var packets = port.buffer.Where(x => x.Item1 + x.Item2.linkDelay <= GlobalTimer.tick).ToList();
                if (packets.Count() > 0)
                {
                    packets.ForEach(x => { x.Item2.ts_arrival = GlobalTimer.tick; recvTimingReq(x.Item2); port.buffer.Remove(x); });
                }
            }
        }
        public new bool recvTimingReq(Packet pkt)
        {
            pkt.ts_issue = GlobalTimer.tick;
            var x = get_req(BitConverter.ToInt32(pkt.ReadData(), 0));
            PacketManager.Collect(pkt);
            Packet new_pkt = new Packet(CMD.ReadResp);
            new_pkt.source = PacketSource.TraceFetcher;
            new_pkt.linkDelay = Config.linkdelay_tracetetcher_to_insp;
            new_pkt.BuildData(SerializationHelper.SerializeObject(x));
            return sendTimingResq(PacketSource.Insp, ref new_pkt);

        }
        public new bool recvFunctionalReq(Packet pkt)
        {
            pkt.ts_issue = GlobalTimer.tick;
            var x = get_req(BitConverter.ToInt32(pkt.ReadData(), 0));
            PacketManager.Collect(pkt);
            Packet new_pkt = new Packet(CMD.ReadResp);
            new_pkt.source = PacketSource.TraceFetcher;
            new_pkt.BuildData(SerializationHelper.SerializeObject(x));
            return sendFunctionalResq(PacketSource.Insp, ref new_pkt);
        }

        public override bool sendFunctionalResq(PacketSource destiny, ref Packet pkt)
        {
            port._slavePort.recvFunctionalResp(pkt);
            return true;
        }

        public override bool sendTimingResq(PacketSource destiny, ref Packet pkt)
        {
            port._slavePort.addPacket(pkt);
            return true;
        }

        /// <summary>
        /// Cycle++
        /// </summary>
        public override void Step()
        {
            cycle++;
            ServeBuffer();

        }
#endregion
    }
}
