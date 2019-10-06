#include <float.h>
#include <math.h>
#include <mpi.h>
#include <stdlib.h>
#include <string.h>

#include "allvars.h"
#include "proto.h"
#include "rdma_socket.h"
#include "receiver.h"

/*! \file gravtree.c
 *  \brief main driver routines for gravitational (short-range) force
 * computation
 *
 *  This file contains the code for the gravitational force computation by
 *  means of the tree algorithm. To this end, a tree force is computed for
 *  all active local particles, and particles are exported to other
 *  processors if needed, where they can receive additional force
 *  contributions. If the TreePM algorithm is enabled, the force computed
 *  will only be the short-range part.
 */

/*! This function computes the gravitational forces for all active
 *  particles.  If needed, a new tree is constructed, otherwise the
 *  dynamically updated tree is used.  Particles are only exported to other
 *  processors when really needed, thereby allowing a good use of the
 *  communication buffer.
 */

int RDMA_MakeAll(void *buf, int count_in_byte, int root, int rdma_group) {
  int local_rank = RDMA_Rank();
  int whole_ranks = rdma_group.ranks;

  if (local_rank == root) {
    AMessage *msg = (AMessage *)1;
    msg = AMessage_create((void *)buf, count_in_byte, 0);
    for (int i = 0; i < whole_ranks; i++) {
      if (i == local_rank) continue;
      send_(rdma_group.loacl.sockets[i], msg);
    }
    AMessage_destroy(msg);
  } else {
    AMessage *msg = (AMessage *)1;
    while (1) {
      buffer = recv_(rdma_group.loacl.sockets[root]);
      if (msg == NULL) continue;
      if (msg.length == count_in_byte && msg.node_id == root) {
        memcpy(buf, msg.buffer, count_in_byte);
        AMessage_destroy(msg);
        break;
      } else {
        buf = NULL;
        break;
      }
    }
  }
  return 0;
}

int RDMA_GetOffsetRank(int offset, int is_right_side, int rdma_group) {
  int local_rank = RDMA_Rank();
  int whole_ranks = rdma_group.ranks;
  int offset_rank;

  if (is_right_side) {
    offset_rank = local_rank + offset;
    if (offset_rank > whole_ranks - 1) {
      offset_rank = offset_rank - whole_ranks;
    }
  } else {
    offset_rank = local_rank - offset;
    if (offset_rank < 0) {
      offset_rank = offset_rank + whole_ranks;
    }
  }

  return offset_rank;
}

int RDMA_ExchangeAll_exp(const void *sendbuf, int sendcount, void *recvbuf,
                         int recvcount, int rdma_group) {
  int local_rank = RDMA_Rank();
  int whole_ranks = rdma_group.ranks;

  AMessage *send_msg;
  AMessage *recv_msg;

  unsigned char *buffer =
      (unsigned char *)malloc(sizeof(unsigned char) * sendcount);

  send_msg = AMessage_create((void *)sendbuf, sendcount, 0);

  int first_send_rank = RDMA_GetOffsetRank(1, 1, rdma_group);
  send_(rdma_group.loacl.sockets[first_send_rank], msg);

  memcpy((unsigned char *)recvbuf + local_rank * recvcount, sendbuf, sendcount);
  for (int i = 2; i < whole_ranks; i++) {
    int send_rank = RDMA_GetOffsetRank(i, 1, rdma_group);
    int recv_rank = RDMA_GetOffsetRank(i - 1, 0, rdma_group);
    send_(rdma_group.loacl.sockets[send_rank], send_msg);

    recv_msg = recv_(rdma_group.loacl.sockets[recv_rank]);
    memcpy((unsigned char *)recvbuf + recv_rank * recvcount, sendbuf,
           sendcount);
    AMessage_destroy(recv_msg);
  }

  int last_recv_rank = RDMA_GetOffsetRank(whole_ranks - 1, 0, rdma_group);
  recv_msg = recv_(rdma_group.loacl.sockets[last_recv_rank]);
  memcpy((unsigned char *)recvbuf + recv_rank * recvcount, sendbuf, sendcount);
  AMessage_destroy(recv_msg);
}

int RDMA_ExchangeAll(const void *sendbuf, int sendcount, void *recvbuf,
                     int recvcount, int rdma_group) {
  int local_rank = RDMA_Rank();
  int whole_ranks = rdma_group.ranks;

  unsigned char *buffer =
      (unsigned char *)malloc(sizeof(unsigned char) * sendcount);
  for (int i = 0; i < rdma_group.ranks; i++) {
    if (local_rank == i) {
      RDMA_MakeAll((void *)sendbuf, sendcount, i, rdma_group);
      memcpy(((unsigned char *)recvbuf) + sendcount * i, buffer, sendcount);
    } else {
      RDMA_MakeAll((void *)((unsigned char *)recvbuf + recvcount * i),
                   recvcount, i, rdma_group);
    }
  }
}

int RDMA_GetAll(const void *sendbuf, int sendcount, void *recvbuf,
                int recvcount, int root, int rdma_group) {
  int local_rank = RDMA_Rank();
  int whole_ranks = rdma_group.ranks;

  if (local_rank == root) {
    for (int i = 0; i < rdma_group.ranks; i++) {
      if (local_rank == i) {
        memcpy(((unsigned char *)recvbuf) + sendcount * i, sendbuf, sendcount);
      } else {
        AMessage *msg = (AMessage *)1;
        while (1) {
          buffer = recv_(rdma_group.local.sockets[i]);
          if (msg == NULL) continue;
          if (msg.length == recvcount && msg.node_id == i) {
            memcpy(((unsigned char *)recvbuf) + sendcount * i, msg.buffer,
                   recvcount);
            AMessage_destroy(msg);
          }
          break;
        }
      }
    }
  } else {
    AMessage *msg;
    msg = AMessage_create((void *)sendbuf, sendcount, 0);
    send_(rdma_group.loacl.sockets[root], msg);
    AMessage_destroy(msg);
  }
}

int RDMA_Scatter(const void *sendbuf, int sendcount, void *recvbuf,
                 int recvcount, int root, int rdma_group) {
  int local_rank = RDMA_Rank();
  int whole_ranks = rdma_group.ranks;

  if (local_rank == root) {
    for (int i = 0; i < rdma_group.ranks; i++) {
      if (local_rank == i) {
        memcpy(recvbuf, ((unsigned char *)sendbuf) + sendcount * i, sendcount);
      } else {
        AMessage *msg;
        msg = AMessage_create(
            (void *)((unsigned char *)sendbuf + sendcount * i), sendcount, 0);
        send_(rdma_group.loacl.sockets[i], msg);
        AMessage_destroy(msg);
      }
    }
  } else {
    AMessage *msg = (AMessage *)1;
    while (1) {
      buffer = recv_(rdma_group.local.sockets[root]);
      if (msg == NULL) continue;
      if (msg.length == recvcount && msg.node_id == i) {
        memcpy(recvbuf, msg.buffer, recvcount);
        AMessage_destroy(msg);
      }
      break;
    }
  }
}

void gravity_tree(void) {
  long long ntot;
  int numnodes, nexportsum = 0;
  int i, j, iter = 0;
  int *numnodeslist, maxnumnodes, nexport, *numlist, *nrecv, *ndonelist;
  double tstart, tend, timetree = 0, timecommsumm = 0, timeimbalance = 0,
                       sumimbalance;
  double ewaldcount;
  double costtotal, ewaldtot, *costtreelist, *ewaldlist;
  double maxt, sumt, *timetreelist, *timecommlist;
  double fac, plb, plb_max, sumcomm;

#ifndef NOGRAVITY
  int *noffset, *nbuffer, *nsend, *nsend_local;
  long long ntotleft;
  int ndone, maxfill, ngrp;
  int k, place;
  int level, sendTask, recvTask;
  double ax, ay, az;
#endif

  /* set new softening lengths */
  if (All.ComovingIntegrationOn) set_softenings();

  /* contruct tree if needed */
  tstart = second();
  if (TreeReconstructFlag) {
    if (ThisTask == 0) printf("Tree construction.\n");

    force_treebuild(NumPart);

    TreeReconstructFlag = 0;

    if (ThisTask == 0) printf("Tree construction done.\n");
  }
  tend = second();
  All.CPU_TreeConstruction += timediff(tstart, tend);

  costtotal = ewaldcount = 0;

  /* Note: 'NumForceUpdate' has already been determined in
   * find_next_sync_point_and_drift() */
  numlist = malloc(NTask * sizeof(int) * NTask);
  RDMA_Allgather(&NumForceUpdate, 1, R_TYPE_INT, numlist, 1, R_TYPE_INT);
  for (i = 0, ntot = 0; i < NTask; i++) ntot += numlist[i];
  free(numlist);

#ifndef NOGRAVITY
  if (ThisTask == 0) printf("Begin tree force.\n");

#ifdef SELECTIVE_NO_GRAVITY
  for (i = 0; i < NumPart; i++)
    if (((1 << P[i].Type) & (SELECTIVE_NO_GRAVITY)))
      P[i].Ti_endstep = -P[i].Ti_endstep - 1;
#endif

  noffset = malloc(sizeof(int) * NTask); /* offsets of bunches in common list */
  nbuffer = malloc(sizeof(int) * NTask);
  nsend_local = malloc(sizeof(int) * NTask);
  nsend = malloc(sizeof(int) * NTask * NTask);
  ndonelist = malloc(sizeof(int) * NTask);

  i = 0;           /* beginn with this index */
  ntotleft = ntot; /* particles left for all tasks together */

  while (ntotleft > 0) {
    iter++;

    for (j = 0; j < NTask; j++) nsend_local[j] = 0;

    /* do local particles and prepare export list */
    tstart = second();
    for (nexport = 0, ndone = 0;
         i < NumPart && nexport < All.BunchSizeForce - NTask; i++)
      if (P[i].Ti_endstep == All.Ti_Current) {
        ndone++;

        for (j = 0; j < NTask; j++) Exportflag[j] = 0;
#ifndef PMGRID
        costtotal += force_treeevaluate(i, 0, &ewaldcount);
#else
        costtotal += force_treeevaluate_shortrange(i, 0);
#endif
        for (j = 0; j < NTask; j++) {
          if (Exportflag[j]) {
            for (k = 0; k < 3; k++) GravDataGet[nexport].u.Pos[k] = P[i].Pos[k];
#ifdef UNEQUALSOFTENINGS
            GravDataGet[nexport].Type = P[i].Type;
#ifdef ADAPTIVE_GRAVSOFT_FORGAS
            if (P[i].Type == 0) GravDataGet[nexport].Soft = SphP[i].Hsml;
#endif
#endif
            GravDataGet[nexport].w.OldAcc = P[i].OldAcc;
            GravDataIndexTable[nexport].Task = j;
            GravDataIndexTable[nexport].Index = i;
            GravDataIndexTable[nexport].SortIndex = nexport;
            nexport++;
            nexportsum++;
            nsend_local[j]++;
          }
        }
      }
    tend = second();
    timetree += timediff(tstart, tend);

    qsort(GravDataIndexTable, nexport, sizeof(struct gravdata_index),
          grav_tree_compare_key);

    for (j = 0; j < nexport; j++)
      GravDataIn[j] = GravDataGet[GravDataIndexTable[j].SortIndex];

    for (j = 1, noffset[0] = 0; j < NTask; j++)
      noffset[j] = noffset[j - 1] + nsend_local[j - 1];

    tstart = second();

    RDMA_Allgather(nsend_local, NTask, R_TYPE_INT, nsend, NTask, R_TYPE_INT);

    tend = second();
    timeimbalance += timediff(tstart, tend);

    /* now do the particles that need to be exported */

    for (level = 1; level < (1 << PTask); level++) {
      tstart = second();
      for (j = 0; j < NTask; j++) nbuffer[j] = 0;
      for (ngrp = level; ngrp < (1 << PTask); ngrp++) {
        maxfill = 0;
        for (j = 0; j < NTask; j++) {
          if ((j ^ ngrp) < NTask)
            if (maxfill < nbuffer[j] + nsend[(j ^ ngrp) * NTask + j])
              maxfill = nbuffer[j] + nsend[(j ^ ngrp) * NTask + j];
        }
        if (maxfill >= All.BunchSizeForce) break;

        sendTask = ThisTask;
        recvTask = ThisTask ^ ngrp;

        if (recvTask < NTask) {
          if (nsend[ThisTask * NTask + recvTask] > 0 ||
              nsend[recvTask * NTask + ThisTask] > 0) {
            /* get the particles */

            MPI_Sendrecv(
                &GravDataIn[noffset[recvTask]],
                nsend_local[recvTask] * sizeof(struct gravdata_in), R_TYPE_BYTE,
                recvTask, TAG_GRAV_A, &GravDataGet[nbuffer[ThisTask]],
                nsend[recvTask * NTask + ThisTask] * sizeof(struct gravdata_in),
                R_TYPE_BYTE, recvTask, TAG_GRAV_A, MPI_COMM_WORLD, &status);
          }
        }

        for (j = 0; j < NTask; j++)
          if ((j ^ ngrp) < NTask) nbuffer[j] += nsend[(j ^ ngrp) * NTask + j];
      }
      tend = second();
      timecommsumm += timediff(tstart, tend);

      tstart = second();
      for (j = 0; j < nbuffer[ThisTask]; j++) {
#ifndef PMGRID
        costtotal += force_treeevaluate(j, 1, &ewaldcount);
#else
        costtotal += force_treeevaluate_shortrange(j, 1);
#endif
      }
      tend = second();
      timetree += timediff(tstart, tend);

      tstart = second();
      RDMA_Barrier();
      tend = second();
      timeimbalance += timediff(tstart, tend);

      /* get the result */
      tstart = second();
      for (j = 0; j < NTask; j++) nbuffer[j] = 0;
      for (ngrp = level; ngrp < (1 << PTask); ngrp++) {
        maxfill = 0;
        for (j = 0; j < NTask; j++) {
          if ((j ^ ngrp) < NTask)
            if (maxfill < nbuffer[j] + nsend[(j ^ ngrp) * NTask + j])
              maxfill = nbuffer[j] + nsend[(j ^ ngrp) * NTask + j];
        }
        if (maxfill >= All.BunchSizeForce) break;

        sendTask = ThisTask;
        recvTask = ThisTask ^ ngrp;
        if (recvTask < NTask) {
          if (nsend[ThisTask * NTask + recvTask] > 0 ||
              nsend[recvTask * NTask + ThisTask] > 0) {
            /* send the results */
            MPI_Sendrecv(
                &GravDataResult[nbuffer[ThisTask]],
                nsend[recvTask * NTask + ThisTask] * sizeof(struct gravdata_in),
                R_TYPE_BYTE, recvTask, TAG_GRAV_B, &GravDataOut[noffset[recvTask]],
                nsend_local[recvTask] * sizeof(struct gravdata_in), R_TYPE_BYTE,
                recvTask, TAG_GRAV_B, MPI_COMM_WORLD, &status);

            /* add the result to the particles */
            for (j = 0; j < nsend_local[recvTask]; j++) {
              place = GravDataIndexTable[noffset[recvTask] + j].Index;

              for (k = 0; k < 3; k++)
                P[place].GravAccel[k] +=
                    GravDataOut[j + noffset[recvTask]].u.Acc[k];

              P[place].GravCost +=
                  GravDataOut[j + noffset[recvTask]].w.Ninteractions;
            }
          }
        }

        for (j = 0; j < NTask; j++)
          if ((j ^ ngrp) < NTask) nbuffer[j] += nsend[(j ^ ngrp) * NTask + j];
      }
      tend = second();
      timecommsumm += timediff(tstart, tend);

      level = ngrp - 1;
    }

    RDMA_Allgather(&ndone, 1, R_TYPE_INT, ndonelist, 1, R_TYPE_INT);
    for (j = 0; j < NTask; j++) ntotleft -= ndonelist[j];
  }

  free(ndonelist);
  free(nsend);
  free(nsend_local);
  free(nbuffer);
  free(noffset);

  /* now add things for comoving integration */

#ifndef PERIODIC
#ifndef PMGRID
  if (All.ComovingIntegrationOn) {
    fac = 0.5 * All.Hubble * All.Hubble * All.Omega0 / All.G;

    for (i = 0; i < NumPart; i++)
      if (P[i].Ti_endstep == All.Ti_Current)
        for (j = 0; j < 3; j++) P[i].GravAccel[j] += fac * P[i].Pos[j];
  }
#endif
#endif

  for (i = 0; i < NumPart; i++)
    if (P[i].Ti_endstep == All.Ti_Current) {
#ifdef PMGRID
      ax = P[i].GravAccel[0] + P[i].GravPM[0] / All.G;
      ay = P[i].GravAccel[1] + P[i].GravPM[1] / All.G;
      az = P[i].GravAccel[2] + P[i].GravPM[2] / All.G;
#else
      ax = P[i].GravAccel[0];
      ay = P[i].GravAccel[1];
      az = P[i].GravAccel[2];
#endif
      P[i].OldAcc = sqrt(ax * ax + ay * ay + az * az);
    }

  if (All.TypeOfOpeningCriterion == 1)
    All.ErrTolTheta = 0; /* This will switch to the relative opening criterion
                            for the following force computations */

  /*  muliply by G */
  for (i = 0; i < NumPart; i++)
    if (P[i].Ti_endstep == All.Ti_Current)
      for (j = 0; j < 3; j++) P[i].GravAccel[j] *= All.G;

        /* Finally, the following factor allows a computation of a cosmological
           simulation with vacuum energy in physical coordinates */
#ifndef PERIODIC
#ifndef PMGRID
  if (All.ComovingIntegrationOn == 0) {
    fac = All.OmegaLambda * All.Hubble * All.Hubble;

    for (i = 0; i < NumPart; i++)
      if (P[i].Ti_endstep == All.Ti_Current)
        for (j = 0; j < 3; j++) P[i].GravAccel[j] += fac * P[i].Pos[j];
  }
#endif
#endif

#ifdef SELECTIVE_NO_GRAVITY
  for (i = 0; i < NumPart; i++)
    if (P[i].Ti_endstep < 0) P[i].Ti_endstep = -P[i].Ti_endstep - 1;
#endif

  if (ThisTask == 0) printf("tree is done.\n");

#else /* gravity is switched off */

  for (i = 0; i < NumPart; i++)
    if (P[i].Ti_endstep == All.Ti_Current)
      for (j = 0; j < 3; j++) P[i].GravAccel[j] = 0;

#endif

  /* Now the force computation is finished */

  /*  gather some diagnostic information */

  timetreelist = malloc(sizeof(double) * NTask);
  timecommlist = malloc(sizeof(double) * NTask);
  costtreelist = malloc(sizeof(double) * NTask);
  numnodeslist = malloc(sizeof(int) * NTask);
  ewaldlist = malloc(sizeof(double) * NTask);
  nrecv = malloc(sizeof(int) * NTask);

  numnodes = Numnodestree;

  RDMA_Gather(&costtotal, 1, R_TYPE_DOUBLE, costtreelist, 1, R_TYPE_DOUBLE, 0);
  RDMA_Gather(&numnodes, 1, R_TYPE_INT, numnodeslist, 1, R_TYPE_INT, 0);
  RDMA_Gather(&timetree, 1, R_TYPE_DOUBLE, timetreelist, 1, R_TYPE_DOUBLE, 0);
  RDMA_Gather(&timecommsumm, 1, R_TYPE_DOUBLE, timecommlist, 1, R_TYPE_DOUBLE, 0);
  RDMA_Gather(&NumPart, 1, R_TYPE_INT, nrecv, 1, R_TYPE_INT, 0);
  RDMA_Gather(&ewaldcount, 1, R_TYPE_DOUBLE, ewaldlist, 1, R_TYPE_DOUBLE, 0);
  RDMA_Gather(&nexportsum, &nexport, 1, R_TYPE_INT, R_OP_SUM, 0);
  RDMA_Gather(&timeimbalance, &sumimbalance, 1, R_TYPE_DOUBLE, R_OP_SUM, 0);

  if (ThisTask == 0) {
    All.TotNumOfForces += ntot;

    fprintf(FdTimings, "Step= %d  t= %g  dt= %g \n", All.NumCurrentTiStep,
            All.Time, All.TimeStep);
    fprintf(FdTimings, "Nf= %d%09d  total-Nf= %d%09d  ex-frac= %g  iter= %d\n",
            (int)(ntot / 1000000000), (int)(ntot % 1000000000),
            (int)(All.TotNumOfForces / 1000000000),
            (int)(All.TotNumOfForces % 1000000000), nexport / ((double)ntot),
            iter);
    /* note: on Linux, the 8-byte integer could be printed with the format
     * identifier "%qd", but doesn't work on AIX */

    fac = NTask / ((double)All.TotNumPart);

    for (i = 0, maxt = timetreelist[0], sumt = 0, plb_max = 0, maxnumnodes = 0,
        costtotal = 0, sumcomm = 0, ewaldtot = 0;
         i < NTask; i++) {
      costtotal += costtreelist[i];

      sumcomm += timecommlist[i];

      if (maxt < timetreelist[i]) maxt = timetreelist[i];
      sumt += timetreelist[i];

      plb = nrecv[i] * fac;

      if (plb > plb_max) plb_max = plb;

      if (numnodeslist[i] > maxnumnodes) maxnumnodes = numnodeslist[i];

      ewaldtot += ewaldlist[i];
    }
    fprintf(FdTimings, "work-load balance: %g  max=%g avg=%g PE0=%g\n",
            maxt / (sumt / NTask), maxt, sumt / NTask, timetreelist[0]);
    fprintf(FdTimings, "particle-load balance: %g\n", plb_max);
    fprintf(FdTimings, "max. nodes: %d, filled: %g\n", maxnumnodes,
            maxnumnodes / (All.TreeAllocFactor * All.MaxPart));
    fprintf(FdTimings, "part/sec=%g | %g  ia/part=%g (%g)\n",
            ntot / (sumt + 1.0e-20), ntot / (maxt * NTask),
            ((double)(costtotal)) / ntot, ((double)ewaldtot) / ntot);
    fprintf(FdTimings, "\n");

    fflush(FdTimings);

    All.CPU_TreeWalk += sumt / NTask;
    All.CPU_Imbalance += sumimbalance / NTask;
    All.CPU_CommSum += sumcomm / NTask;
  }

  free(nrecv);
  free(ewaldlist);
  free(numnodeslist);
  free(costtreelist);
  free(timecommlist);
  free(timetreelist);
}

/*! This function sets the (comoving) softening length of all particle
 *  types in the table All.SofteningTable[...].  We check that the physical
 *  softening length is bounded by the Softening-MaxPhys values.
 */
void set_softenings(void) {
  int i;

  if (All.ComovingIntegrationOn) {
    if (All.SofteningGas * All.Time > All.SofteningGasMaxPhys)
      All.SofteningTable[0] = All.SofteningGasMaxPhys / All.Time;
    else
      All.SofteningTable[0] = All.SofteningGas;

    if (All.SofteningHalo * All.Time > All.SofteningHaloMaxPhys)
      All.SofteningTable[1] = All.SofteningHaloMaxPhys / All.Time;
    else
      All.SofteningTable[1] = All.SofteningHalo;

    if (All.SofteningDisk * All.Time > All.SofteningDiskMaxPhys)
      All.SofteningTable[2] = All.SofteningDiskMaxPhys / All.Time;
    else
      All.SofteningTable[2] = All.SofteningDisk;

    if (All.SofteningBulge * All.Time > All.SofteningBulgeMaxPhys)
      All.SofteningTable[3] = All.SofteningBulgeMaxPhys / All.Time;
    else
      All.SofteningTable[3] = All.SofteningBulge;

    if (All.SofteningStars * All.Time > All.SofteningStarsMaxPhys)
      All.SofteningTable[4] = All.SofteningStarsMaxPhys / All.Time;
    else
      All.SofteningTable[4] = All.SofteningStars;

    if (All.SofteningBndry * All.Time > All.SofteningBndryMaxPhys)
      All.SofteningTable[5] = All.SofteningBndryMaxPhys / All.Time;
    else
      All.SofteningTable[5] = All.SofteningBndry;
  } else {
    All.SofteningTable[0] = All.SofteningGas;
    All.SofteningTable[1] = All.SofteningHalo;
    All.SofteningTable[2] = All.SofteningDisk;
    All.SofteningTable[3] = All.SofteningBulge;
    All.SofteningTable[4] = All.SofteningStars;
    All.SofteningTable[5] = All.SofteningBndry;
  }

  for (i = 0; i < 6; i++) All.ForceSoftening[i] = 2.8 * All.SofteningTable[i];

  All.MinGasHsml = All.MinGasHsmlFractional * All.ForceSoftening[0];
}

/*! This function is used as a comparison kernel in a sort routine. It is
 *  used to group particles in the communication buffer that are going to
 *  be sent to the same CPU.
 */
int grav_tree_compare_key(const void *a, const void *b) {
  if (((struct gravdata_index *)a)->Task < (((struct gravdata_index *)b)->Task))
    return -1;

  if (((struct gravdata_index *)a)->Task > (((struct gravdata_index *)b)->Task))
    return +1;

  return 0;
}
