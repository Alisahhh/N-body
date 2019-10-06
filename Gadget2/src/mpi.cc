#include "mpi.hpp"
#include "fmpi.hpp"
#include "receiver.h"
#include "rdma_socket.h"
#include <string.h>
#include <cstdio>
#include <algorithm>

using namespace std;

int RDMA_Bcast(void *buf, int count_in_byte, int type ,int root)
{
    int local_rank = RDMA_Rank();
    int whole_ranks = RDMA_Size();
    int res =-1;

    count_in_byte*=type_static[type];

    if(buf == NULL) return 1;
    if(count_in_byte <= 0) return 2;
    if(root >= whole_ranks || root < 0) return 3;


    if (local_rank == root)
    {
        AMessage *msg = (AMessage *)1;
        msg = AMessage_create((void *)buf, count_in_byte, 0);
        for (int i = 0; i < whole_ranks; i++)
        {
            printf("socket:%x\n",RDMA_Socket(i));
            if (i == local_rank) continue;
            res = send_(RDMA_Socket(i), msg);
            if(res != 0) {AMessage_destroy(msg);return res;}
        }
        AMessage_destroy(msg);
    }
    else
    {
        auto msg = recv_(RDMA_Socket(root));
        if (msg == NULL)
            return 4;
        if (msg->length == count_in_byte)
        {
            memcpy(buf, msg->buffer, count_in_byte);
            AMessage_destroy(msg);
        }else{
            AMessage_destroy(msg);
            return 5;
        }
    }
    return 0;
}

int RDMA_GetOffsetRank(int offset, int is_right_side)
{
    int local_rank = RDMA_Rank();
    int whole_ranks = RDMA_Size();
    int offset_rank;

    if (is_right_side)
    {
        offset_rank = local_rank + offset;
        if (offset_rank > whole_ranks - 1)
        {
            offset_rank = offset_rank - whole_ranks;
        }
    }
    else
    {
        offset_rank = local_rank - offset;
        if (offset_rank < 0)
        {
            offset_rank = offset_rank + whole_ranks;
        }
    }

    return offset_rank;
}

int RDMA_Allgather_exp(void *sendbuf, int sendcount, int sendtype, void *recvbuf,
                         int recvcount, int recvtype)
{
    int local_rank = RDMA_Rank();
    int whole_ranks = RDMA_Size();
    int res =-1;

    if(sendbuf == NULL || recvbuf == NULL) return 1;
    if(sendcount <= 0 || recvcount <= 0) return 2;

    sendcount*=type_static[sendtype];
    recvcount*=type_static[recvtype];

    auto send_msg = AMessage_create((void *)sendbuf, sendcount, 0);

    int first_send_rank = RDMA_GetOffsetRank(1, 1);
    res = send_(RDMA_Socket(first_send_rank), send_msg);
    if(res != 0) {AMessage_destroy(send_msg);return res;}

    memcpy((unsigned char *)recvbuf + local_rank * recvcount, sendbuf, sendcount);
    for (int i = 2; i < whole_ranks; i++)
    {
        int send_rank = RDMA_GetOffsetRank(i, 1);
        int recv_rank = RDMA_GetOffsetRank(i - 1, 0);

        res = send_(RDMA_Socket(send_rank), send_msg);
        if(res != 0) {AMessage_destroy(send_msg);return res;}

        auto recv_msg = recv_(RDMA_Socket(recv_rank));
        if(recv_msg == NULL) {
            AMessage_destroy(send_msg);
            return 4;
        }
        memcpy((unsigned char *)recvbuf + recv_rank * recvcount, recv_msg->buffer,
               sendcount);
        AMessage_destroy(recv_msg);
    }
    AMessage_destroy(send_msg);

    int last_recv_rank = RDMA_GetOffsetRank(whole_ranks - 1, 0);
    auto recv_msg = recv_(RDMA_Socket(last_recv_rank));
    if(recv_msg == NULL){
        AMessage_destroy(recv_msg);
        return 4;
    }
    memcpy((unsigned char *)recvbuf + last_recv_rank * recvcount, recv_msg->buffer, sendcount);
    AMessage_destroy(recv_msg);

    return 0;
}

int RDMA_Allgatherv_exp(void *sendbuf, int sendcount, int sendtype, void *recvbuf,
                         int *recvcount, int *displs, int recvtype)
{
    int local_rank = RDMA_Rank();
    int whole_ranks = RDMA_Size();
    int res =-1;

    if(sendbuf == NULL || recvbuf == NULL) return 1;
    if(sendcount <= 0 || recvcount <= 0) return 2;

    sendcount*=type_static[sendtype];
    for(int i=0;i<whole_ranks;i++){
        recvcount[i]*=type_static[recvtype];
        displs[i]*=type_static[recvtype];
    }

    auto send_msg = AMessage_create((void *)sendbuf, sendcount, 0);

    int first_send_rank = RDMA_GetOffsetRank(1, 1);
    res = send_(RDMA_Socket(first_send_rank), send_msg);
    if(res != 0) {AMessage_destroy(send_msg);return res;}

    memcpy((unsigned char *)recvbuf + displs[local_rank], sendbuf, sendcount);
    for (int i = 2; i < whole_ranks; i++)
    {
        int send_rank = RDMA_GetOffsetRank(i, 1);
        int recv_rank = RDMA_GetOffsetRank(i - 1, 0);

        res = send_(RDMA_Socket(send_rank), send_msg);
        if(res != 0) {AMessage_destroy(send_msg);return res;}

        auto recv_msg = recv_(RDMA_Socket(recv_rank));
        if(recv_msg == NULL) {
            AMessage_destroy(send_msg);
            return 4;
        }
        if(recv_msg->length != recvcount[i]){
            AMessage_destroy(send_msg);
            return 5;
        }
        memcpy((unsigned char *)recvbuf + displs[i], recv_msg->buffer,
               recvcount[i]);
        AMessage_destroy(recv_msg);
    }
    AMessage_destroy(send_msg);

    int last_recv_rank = RDMA_GetOffsetRank(whole_ranks - 1, 0);
    auto recv_msg = recv_(RDMA_Socket(last_recv_rank));
    if(recv_msg == NULL){
        AMessage_destroy(send_msg);
        return 4;
    }
    if(recv_msg->length != recvcount[last_recv_rank]) {
        AMessage_destroy(send_msg);
        return 5;
    }
    memcpy((unsigned char *)recvbuf + displs[last_recv_rank], recv_msg->buffer, recvcount[last_recv_rank]);
    AMessage_destroy(recv_msg);

    return 0;
}

int RDMA_Allgather(void *sendbuf, int sendcount, int sendtype, void *recvbuf,
                     int recvcount, int recvtype)
{
    int local_rank = RDMA_Rank();
    int whole_ranks = RDMA_Size();
    int res =-1;

    if(sendbuf == NULL || recvbuf == NULL) return 1;
    if(sendcount <= 0 || recvcount <= 0) return 2;

    sendcount*=type_static[sendtype];
    recvcount*=type_static[recvtype];

    for (int i = 0; i < whole_ranks; i++)
    {
        if (local_rank == i)
        {
            res = RDMA_Bcast((void *)sendbuf, sendcount, sendtype, i);
            if(res != 0) return res;

            memcpy(((unsigned char *)recvbuf) + sendcount * i, sendbuf, sendcount);
        }
        else
        {
            res = RDMA_Bcast((void *)((unsigned char *)recvbuf + recvcount * i),
                         recvcount, recvtype, i);
            if(res != 0) return res;
        }
    }

    return 0;
}

int RDMA_Gather(void *sendbuf, int sendcount, int sendtype, void *recvbuf,
                int recvcount, int recvtype, int root)
{
    int local_rank = RDMA_Rank();
    int whole_ranks = RDMA_Size();
    int res =-1;

    if(sendbuf == NULL || recvbuf == NULL) return 1;
    if(sendcount <= 0 || recvcount <= 0) return 2;
    if(root >= whole_ranks || root < 0) return 3;

    sendcount*=type_static[sendtype];
    recvcount*=type_static[recvtype];

    if (local_rank == root)
    {
        for (int i = 0; i < whole_ranks; i++)
        {
            if (local_rank == i)
            {
                memcpy(((unsigned char *)recvbuf) + sendcount * i, sendbuf, sendcount);
            }
            else
            {
                AMessage *msg = (AMessage *)1;
                msg = recv_(RDMA_Socket(i));
                if (msg == NULL)
                    return 4;
                if (msg->length == recvcount)
                {
                    memcpy(((unsigned char *)recvbuf) + recvcount * i, msg->buffer,
                            recvcount);
                    AMessage_destroy(msg);
                }else{
                    AMessage_destroy(msg);
                    return 5;
                }
            }
        }
    }
    else
    {
        AMessage *msg;
        msg = AMessage_create((void *)sendbuf, sendcount, 0);
        res = send_(RDMA_Socket(root), msg);
        AMessage_destroy(msg);
        if(res != 0) return res;
    }

    return 0;
}

int RDMA_Scatter(void *sendbuf, int sendcount, int sendtype, void *recvbuf,
                 int recvcount, int recvtype, int root)
{
    int local_rank = RDMA_Rank();
    int whole_ranks = RDMA_Size();
    int res =-1;

    if(sendbuf == NULL || recvbuf == NULL) return 1;
    if(sendcount <= 0 || recvcount <= 0) return 2;
    if(root >= whole_ranks || root < 0) return 3;

    sendcount*=type_static[sendtype];
    recvcount*=type_static[recvtype];

    if (local_rank == root)
    {
        for (int i = 0; i < RDMA_Size(); i++)
        {
            if (local_rank == i)
            {
                memcpy(recvbuf, ((unsigned char *)sendbuf) + sendcount * i, sendcount);
            }
            else
            {
                AMessage *msg;
                msg = AMessage_create(
                    (void *)((unsigned char *)sendbuf + sendcount * i), sendcount, 0);
                res = send_(RDMA_Socket(i), msg);
                if(res != 0){AMessage_destroy(msg);return res;}
                AMessage_destroy(msg);
            }
        }
    }
    else
    {
        AMessage *msg = (AMessage *)1;
        msg = recv_(RDMA_Socket(root));
        if (msg == NULL)
            return -1;
        if (msg->length == recvcount)
        {
            memcpy(recvbuf, msg->buffer, recvcount);
            AMessage_destroy(msg);
        }else{
            AMessage_destroy(msg);
            return 5;
        }
    }

    return 0;
}

int RDMA_Send(void *buf, int count,int type, int dest)
{
    int local_rank = RDMA_Rank();
    int res = -1;

    if (buf == NULL) return 1;
    if (count < 0) return 2;
    if (dest == local_rank) return 3;

    count *= type_static[type];

    auto msg = AMessage_create(buf, count, 0);
    Socket *socket = RDMA_Socket(dest);
    res = send_(socket, msg);
    AMessage_destroy(msg);

    return res;
}

int RDMA_Recv(void *buf, int count, int type, int source)
{
    int local_rank = RDMA_Rank();
    int res = 0;

    if (buf == NULL) return 1;
    if (count < 0) return 2;
    if (source == local_rank) return 3;

    count *= type_static[type];

    Socket *listen = RDMA_Socket(source);
    AMessage *msg = (AMessage *)1;
    msg = recv_(listen);
    if (msg->length == count && msg->node_id == source)
    {
        memcpy(buf, msg->buffer, count);
    }
    else
    {
        buf = nullptr;
    }

    AMessage_destroy(msg);
    return res;
}

int RDMA_Irecv(void *buf, int count, int type, int source)
{
    int local_rank = RDMA_Rank();
    int rc = 0;

    if (buf == NULL) return 1;
    if (count < 0) return 2;
    if (source == local_rank) return 3;

    count *= type_static[type];

    Socket *listen = RDMA_Socket(source);

    AMessage *msg = (AMessage *)1;
    msg = irecv_(listen);
    if(listen->close_flag == 1){
        return 1;
    }
    if (msg->length == count && msg->node_id == source)
    {
        memcpy(buf, msg->buffer, count);
    }
    else
    {
        rc = 1;
        buf = nullptr;
    }
    AMessage_destroy(msg);
    return rc;
}

// datatype  0 double 1 int 2 long int
// op 0 sum 1 min 2 max

int RDMA_Reduce(void *sendbuf, void *recvbuf, int count,
                int datatype, int op, int root)
{
    int local_rank = RDMA_Rank();
    int whole_rank = RDMA_Size();
    // printf("%d %d %d %d\n", local_rank, whole_rank, root, count);
    if (local_rank == root)
    {
        memcpy(recvbuf, sendbuf, count);
        // printf("memcpy success\n");
        AMessage *msg = (AMessage *)1;
        for (int i = 0; i < whole_rank; i++)
        {
            if (i == root)
                continue;
            Socket *listen = RDMA_Socket(i);
            msg = recv_(listen);
            // printf("success recv\n");
            if (datatype == 0)
            {
                double *resbuf = (double *)recvbuf;
                double *msgbuffer = (double *)msg->buffer;
                if (op == 0)
                {
                    for (int j = 0; j < count/8; j++)
                    {
                        // printf("%lf %lf\n", resbuf[j], msgbuffer[j]);
                        resbuf[j] = resbuf[j] + msgbuffer[j];
                        // printf("%lf %lf\n", resbuf[j], msgbuffer[j]);
                    }
                }
                else if (op == 1)
                {
                    for (int j = 0; j < count/8; j++)
                    {
                        resbuf[j] = min(resbuf[j], msgbuffer[j]);
                    }
                }
                else
                {
                    for (int j = 0; j < count/8; j++)
                    {
                        resbuf[j] = max(resbuf[j], msgbuffer[j]);
                    }
                }
            }
            else if (datatype == 1)
            {
                int *resbuf = (int*)recvbuf;
                int *msgbuffer = (int *)msg->buffer;
                if (op == 0)
                {
                    for (int j = 0; j < count / 4; j++)
                    {
                        // printf("%d %d\n", resbuf[j], msgbuffer[j]);
                        resbuf[j] = resbuf[j] + msgbuffer[j];
                        // printf("%d %d\n", resbuf[j], msgbuffer[j]);
                    }
                }
                else if (op == 1)
                {
                    for (int j = 0; j < count / 4; j++)
                    {
                        resbuf[j] = min(resbuf[j], msgbuffer[j]);
                    }
                }
                else
                {
                    for (int j = 0; j < count / 4; j++)
                    {
                        resbuf[j] = max(resbuf[j], msgbuffer[j]);
                    }
                }
                // for (int i = 0; i < 5;i ++)
                //     printf("%d ", *((int*)(recvbuf+i*4)));
                
            }
            else if (datatype == 2)
            {
                long long *resbuf = (long long *)recvbuf;
                long long *msgbuffer = (long long *)msg->buffer;
                if (op == 0)
                {
                    for (int j = 0; j < count/8; j++)
                    {
                        resbuf[j] = resbuf[j] + msgbuffer[j];
                    }
                }
                else if (op == 1)
                {
                    for (int j = 0; j < count/8; j++)
                    {
                        resbuf[j] = min(resbuf[j], msgbuffer[j]);
                    }
                }
                else
                {
                    for (int j = 0; j < count/8; j++)
                    {
                        resbuf[j] = max(resbuf[j], msgbuffer[j]);
                    }
                }
            }
        }
        AMessage_destroy(msg);
    }
    else
    {
        auto msg = AMessage_create(sendbuf, count, 0);
        Socket *socket = RDMA_Socket(root);
        send_(socket, msg);
        AMessage_destroy(msg);
    }
    return 0;
}

int RDMA_Allreduce(void *sendbuf, void *recvbuf,
                   int count, int datatype, int op)
{
    int local_rank = RDMA_Rank();

    RDMA_Reduce(sendbuf, recvbuf, count, datatype, op, 0);

    if (local_rank == 0)
    {
        RDMA_Bcast(recvbuf, count, datatype, 0);
    }
    return 0;
}

int RDMA_Barrier(){
    int local_rank = RDMA_Rank();
    int whole_rank = RDMA_Size(); 
    // printf("whole_rank = %d \n",whole_rank);
    if(local_rank == 0){
        int id = 1;
        for(int i = 1;i<whole_rank;i ++){
            auto socket = RDMA_Socket(i); 
            auto *buffer = recv_(socket);
            AMessage_destroy(buffer);
        }
        char finish[1] = {'0'};
        RDMA_Bcast(finish,1,0,0);
        return 0;
    }else{
        auto socket = RDMA_Socket(0);
        char finish[1] = {'0'};
        auto msg = AMessage_create((void *)(finish), 1, 0);
        int flag = send_(socket,msg);
        // printf("flag = %d\n",flag);
        AMessage_destroy(msg);
        recv_(socket);
        return 0;
    }
}

int TestIrecv(){
    printf("begin recv\n");
    int local_rank = RDMA_Rank();
    if(local_rank == 0){
        while(1){
            auto socket = RDMA_Socket(1); 
            auto *buffer = irecv_(socket);
            if(buffer!=NULL){
                printf("recv!\n");
                break;
            }
        }
    }else{
        auto socket = RDMA_Socket(0);
        char finish[1] = {'0'};
        auto msg = AMessage_create((void *)(finish), 1, 0);
        int flag = send_(socket,msg);
    }
}