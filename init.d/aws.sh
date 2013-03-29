#!/bin/bash
#
# Amazon Web Service Tool command.
#
# Example of use
# $ awsinstance.sh start <instance's tag_name>
#
. config.sh

TAG_NAME=""
INSTANCE_ID=""
ELASTIC_IP=""
AVAILABILITY_ZONE=""

if [ $# -ne 2 ]; then
    echo "Please specify one argument. If so, please specify the name of the instance tag." 1>&2
    exit 1
else
   TAG_NAME=$2
   echo $TAG_NAME
fi


start(){
    echo -n $"Start AWS Instance $INSTANCE_ID Please Wait about 30sec..."
    echo ""

    # start instance
    ec2-start-instances $INSTANCE_ID

    ## If you want to associate global IP at the same time..
    #sleep 30
    #addip

}

stop() {
    echo -n $"Stopping AWS Instance $INSTANCE_ID Please Wait about 3 min..."
    echo ""

    # stop instance
    ec2-stop-instances $INSTANCE_ID

    ## If you want to create AMI (EBS)..
    #sleep 60
    #ec2-create-image $INSTANCE_ID -n $TAG_NAME-_`date --date 'today' '+%Y%m%d'` -d "${TAG_NAME} Images" --region $AVAILABILITY_ZONE

}

status() {
    ec2-describe-instances | grep -E "${TAG_NAME}"\|"${INSTANCE_ID}"
}

addip() {
    # associate groval IP
    ec2-associate-address -i $INSTANCE_ID $ELASTIC_IP
}

removeip() {
    # disassociate
    ec2-disassociate-address $ELASTIC_IP
}

getinfo(){
    INSTANCE_ID=`ec2-describe-instances | grep -E "${TAG_NAME}" | cut -f3`
    AVAILABILITY_ZONE=`ec2-describe-instances | grep -E "${INSTANCE_ID}" | cut -f12`

    getElasticIp #`ec2-describe-instances | grep -E "${INSTANCE_ID}" | cut -f17`
}

getElasticIp() {
    case "$TAG_NAME" in
        xx_server)
            ELASTIC_IP="xx1.xx2.xx3.xx4"
            ;;
        yy_server)
            ELASTIC_IP="yy1.yy2.yy3.yy4"
            ;;
        *)
            ELASTIC_IP=""
            ;;
    esac
}

# See how we were called.
case "$1" in
    start)
        getinfo
        start
        ;;
    stop)
        getinfo
        stop
        ;;
    status)
        getinfo
        status
        ;;
    addip)
        getinfo
        addip
        ;;
    removeip)
        getinfo
        removeip
        ;;
    restart)
        getinfo
        stop
        start
        ;;
    *)
        echo $"Usage: $prog {start|stop|restart|status|addip|rmip}"
        exit 1
esac

