--- ģ�鹦�ܣ�GPS���ܲ���.
-- @author openLuat
-- @module gps.gpsaliyun
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.23

module(...,package.seeall)

require"gps"
require"agps"
require"aLiYun"
require"misc"
require"pm"
--- ģ�鹦�ܣ������ƹ��ܲ���.
-- ֧�����ݴ����OTA����
-- @author openLuat
-- @module aLiYun.gpsaliyun
-- @license MIT
-- @copyright openLuat
-- @release 2018.04.14

--����һ��һ����֤����ʱ��
--PRODUCT_KEYΪ�����ƻ���2վ���ϴ����Ĳ�Ʒ��ProductKey���û�����ʵ��ֵ�����޸�
local PRODUCT_KEY = "a1b5TD32Zdl"
--���������PRODUCT_KEY�⣬����Ҫ�ṩ��ȡDeviceName�ĺ�������ȡDeviceSecret�ĺ���
--�豸����ʹ�ú���getDeviceName�ķ���ֵ��Ĭ��Ϊ�豸��IMEI
--�豸��Կʹ�ú���getDeviceSecret�ķ���ֵ��Ĭ��Ϊ�豸��SN
--�������ʱ������ֱ���޸�getDeviceName��getDeviceSecret�ķ���ֵ
--��������ʱ��ʹ���豸��IMEI��SN������������ģ�飬����Ψһ��IMEI���û��������Լ��Ĳ�������д���IMEI���豸���ƣ���Ӧ��SN���豸��Կ��
--�����û��Խ�һ�����������豸�ϱ�IMEI�������������������ض�Ӧ���豸��Կ��Ȼ�����misc.setSn�ӿ�д���豸��SN��

--����һ��һ����֤����ʱ��
--PRODUCT_KEY��PRODUCE_SECRETΪ�����ƻ���2վ���ϴ����Ĳ�Ʒ��ProductKey��ProductSecret���û�����ʵ��ֵ�����޸�
--local PRODUCT_KEY = "b1KCi45LcCP"
--local PRODUCE_SECRET = "VWll9fiYWKiwraBk"
--���������PRODUCT_KEY��PRODUCE_SECRET�⣬����Ҫ�ṩ��ȡDeviceName�ĺ�������ȡDeviceSecret�ĺ���������DeviceSecret�ĺ���
--�豸��һ����ĳ��product��ʹ��ʱ������ȥ�ƶ˶�̬ע�ᣬ��ȡ��DeviceSecret�󣬵�������DeviceSecret�ĺ�������DeviceSecret


local function printGps()
    if gps.isOpen() then
        local tLocation = gps.getLocation()
        local speed = gps.getSpeed()
        log.info("gpsaliyun.printGps",
            gps.isOpen(),gps.isFix(),
            tLocation.lngType,tLocation.lng,tLocation.latType,tLocation.lat,
            gps.getAltitude(),
            speed,
            gps.getCourse(),
            gps.getViewedSateCnt(),
            gps.getUsedSateCnt())
        publishTest()
    end
    
end

local function test1Cb(tag)
    log.info("gpsaliyun.test1Cb",tag)
    printGps()
end

local function test()
    --��1�ֲ��Դ���
    --ִ�����������д����GPS�ͻ�һֱ��������Զ����ر�
    --��Ϊgps.open(gps.DEFAULT,{tag="TEST1",cb=test1Cb})�����������û�е���gps.close�ر�
    gps.open(gps.DEFAULT,{tag="TEST1",cb=test1Cb})
end

--[[
��������nemacb
����  ��NEMA���ݵĴ���ص�����
����  ��
		data��һ��NEMA����
����ֵ����
]]
local function nmeaCb(nmeaItem)
    log.info("gpsaliyun.nmeaCb",nmeaItem)
end


--[[
��������getDeviceName
����  ����ȡ�豸����
����  ����
����ֵ���豸����
]]
local function getDeviceName()
    --Ĭ��ʹ���豸��IMEI��Ϊ�豸���ƣ��û����Ը�����Ŀ���������޸�    
    return "DVC1"
    
    --�û��������ʱ�������ڴ˴�ֱ�ӷ��ذ����Ƶ�iot����̨��ע����豸���ƣ�����return "862991419835241"
    --return "862991419835241"
end

--[[
��������getDeviceSecret
����  ����ȡ�豸��Կ
����  ����
����ֵ���豸��Կ
]]
local function getDeviceSecret()
    --Ĭ��ʹ���豸��SN��Ϊ�豸��Կ���û����Ը�����Ŀ���������޸�
    return "WNmXOwEsuKE4zbLWeXOel9vdMNUQSsLD"
    --�û��������ʱ�������ڴ˴�ֱ�ӷ��ذ����Ƶ�iot����̨�����ɵ��豸��Կ������return "y7MTCG6Gk33Ux26bbWSpANl4OaI0bg5Q"
    --return "y7MTCG6Gk33Ux26bbWSpANl4OaI0bg5Q"
end

--�����ƿͻ����Ƿ�������״̬
local sConnected

local publishCnt = 1

--[[
��������pubqos1testackcb
����  ������1��qosΪ1����Ϣ���յ�PUBACK�Ļص�����
����  ��
		usertag������mqttclient:publishʱ�����usertag
		result��true��ʾ�����ɹ���false����nil��ʾʧ��
����ֵ����
]]
local function publishTestCb(result,para)
    log.info("gpsaliyun.publishTestCb",result,para)
    sys.timerStart(publishTest,60000)
    publishCnt = publishCnt+1
end

--����һ��QOSΪ1����Ϣ
function publishTest()
    
    if sConnected then
        local tLocation = gps.getLocation()
        log.info("gpsaliyun.mqtt",
        tLocation.lngType,tLocation.lng,tLocation.latType,tLocation.lat)
        --ע�⣺�ڴ˴��Լ�ȥ����payload�����ݱ��룬aLiYun���в����payload���������κα���ת��
        -- topic: /sys/..PRODUCT_KEY../..getDeviceName()../thing/event/property/post
        aLiYun.publish(
            "/sys/"..PRODUCT_KEY.."/"..getDeviceName().."/thing/event/property/post",
            "\"params\":{\"GeoLocation\":{\"CoordinateSystem\":1,\"Latitude\":"..tLocation.lat..",\"Longitude\":"..tLocation.lng..",\"Altitude\":"..gps.getAltitude().."}}",
            1,
            publishTestCb,
            "publishTest_"..publishCnt)
    end
end

---���ݽ��յĴ�����
-- @string topic��UTF8�������Ϣ����
-- @number qos����Ϣ�����ȼ�
-- @string payload��ԭʼ�������Ϣ����
local function rcvCbFnc(topic,qos,payload)
    log.info("gpsaliyun.rcvCbFnc",topic,qos,payload)
end

--- ���ӽ���Ĵ�����
-- @bool result�����ӽ����true��ʾ���ӳɹ���false����nil��ʾ����ʧ��
local function connectCbFnc(result)
    log.info("gpsaliyun.connectCbFnc",result)
    sConnected = result
    if result then
        --�������⣬����Ҫ���Ƕ��Ľ�����������ʧ�ܣ�aLiYun���л��Զ�����
        aLiYun.subscribe({["/"..PRODUCT_KEY.."/"..getDeviceName().."/get"]=0, ["/"..PRODUCT_KEY.."/"..getDeviceName().."/get"]=1})
        --ע�����ݽ��յĴ�����
        aLiYun.on("receive",rcvCbFnc)
        -- --PUBLISH��Ϣ����
        -- publishTest()
    end
end

-- ��֤����Ĵ�����
-- @bool result����֤�����true��ʾ��֤�ɹ���false����nil��ʾ��֤ʧ��
local function authCbFnc(result)
    log.info("gpsaliyun.authCbFnc",result)
end




--Ҫʹ�ð�����OTA���ܣ�����ο����ļ�124����126��aLiYun.setupȥ���ò���
--Ȼ����ذ�����OTA����ģ��(������Ĵ���ע��)
-- require"aLiYunOta"
--������ð�����OTA����ȥ������������ģ����¹̼���Ĭ�ϵĹ̼��汾�Ÿ�ʽΪ��_G.PROJECT.."_".._G.VERSION.."_"..sys.getcorever()�����ؽ�����ֱ���������򵽴�Ϊֹ������Ҫ�ٿ�����˵��


--���������������ģ����¹̼������ؽ������Լ������Ƿ�����
--������ð�����OTA����ȥ��������������������ģ����ӵ�MCU�������������ʵ�������������Ĵ���ע�ͣ��������ýӿڽ������úʹ���
--����MCU��ǰ���еĹ̼��汾��
--aLiYunOta.setVer("MCU_VERSION_1.0.0")
--�����¹̼����غ󱣴���ļ���
--aLiYunOta.setName("MCU_FIRMWARE.bin")

--[[
��������otaCb
����  ���¹̼��ļ����ؽ�����Ļص�����
        ͨ��uart1��115200,8,uart.PAR_NONE,uart.STOP_1�������سɹ����ļ������͵�MCU�����ͳɹ���ɾ�����ļ�
����  ��
		result�����ؽ����trueΪ�ɹ���falseΪʧ��
		filePath���¹̼��ļ����������·����ֻ��resultΪtrueʱ���˲�����������
����ֵ����
]]
local function otaCb(result,filePath)
    log.info("gpsaliyun.otaCb",result,filePath)
    if result then
        local uartID = 1
        sys.taskInit(
            function()                
                local fileHandle = io.open(filePath,"rb")
                if not fileHandle then
                    log.error("gpsaliyun.otaCb open file error")
                    if filePath then os.remove(filePath) end
                    return
                end
                
                pm.wake("UART_SENT2MCU")
                uart.on(uartID,"sent",function() sys.publish("UART_SENT2MCU_OK") end)
                uart.setup(uartID,115200,8,uart.PAR_NONE,uart.STOP_1,nil,1)
                while true do
                    local data = fileHandle:read(1460)
                    if not data then break end
                    uart.write(uartID,data)
                    sys.waitUntil("UART_SENT2MCU_OK")
                end
                --�˴��ϱ��¹̼��汾�ţ���������ʹ�ã�
                --�û������Լ��ĳ���ʱ�����������������¹̼���ִ����������
                --�����ɹ��󣬵���aLiYunOta.setVer�ϱ��¹̼��汾��
                --�������ʧ�ܣ�����aLiYunOta.setVer�ϱ��ɹ̼��汾��
                aLiYunOta.setVer("MCU_VERSION_1.0.1")
                
                uart.close(uartID)
                pm.sleep("UART_SENT2MCU")
                fileHandle:close()
                if filePath then os.remove(filePath) end
            end
        )

        
    else
        --�ļ�ʹ����֮������Ժ���������Ҫ����ɾ��
        if filePath then os.remove(filePath) end
    end    
end


--�����¹̼����ؽ���Ļص�����
--aLiYunOta.setCb(otaCb)


--����GPS+BD��λ
--��������ô˽ӿڣ�Ĭ��ҲΪGPS+BD��λ
--gps.setAerialMode(1,1,0,0)

--���ý�gps.lua�ڲ�����NEMA����
--��������ô˽ӿڣ�Ĭ��ҲΪ��gps.lua�ڲ�����NEMA����
--���gps.lua�ڲ���������NMEA����ͨ���ص�����cb�ṩ���ⲿ��������������Ϊ1,nmeaCb
--���gps.lua���ⲿ���򶼴�����������Ϊ2,nmeaCb
gps.setNmeaMode(2,nmeaCb)

test()
sys.timerLoopStart(printGps,2000)
sys.timerLoopStart(publishTest,60000)

--����һ��һ����֤����ʱ��
--���ã�ProductKey����ȡDeviceName�ĺ�������ȡDeviceSecret�ĺ���������aLiYun.setup�еĵڶ����������봫��nil
aLiYun.setup(PRODUCT_KEY,nil,getDeviceName,getDeviceSecret)

--����һ��һ����֤����ʱ��
--���ã�ProductKey��ProductSecret����ȡDeviceName�ĺ�������ȡDeviceSecret�ĺ���������DeviceSecret�ĺ���
--aLiYun.setup(PRODUCT_KEY,PRODUCE_SECRET,getDeviceName,getDeviceSecret,setDeviceSecret)

--setMqtt�ӿڲ��Ǳ���ģ�aLiYun.lua��������ӿ����õĲ���Ĭ��ֵ�����Ĭ��ֵ���㲻�����󣬲ο�����ע�͵��Ĵ��룬ȥ���ò���
--aLiYun.setMqtt(0)
aLiYun.on("auth",authCbFnc)
aLiYun.on("connect",connectCbFnc)