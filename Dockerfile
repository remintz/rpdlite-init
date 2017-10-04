FROM nodered/node-red-docker:rpi
USER root
RUN apt-get install bluetooth bluez libbluetooth-dev libudev-dev
RUN npm install node-red-node-arduino
RUN npm install node-red-dashboard
RUN npm install node-red-contrib-sensortag
EXPOSE 1880
CMD ["npm", "start", "--", "--userDir", "/data"]
