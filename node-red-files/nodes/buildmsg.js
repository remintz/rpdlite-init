module.exports = function (RED) {

   function buildMsgNode(config) {
      RED.nodes.createNode(this, config);
      var node = this;
      var context = this.context();
      var globalContext = this.context().global;

      this.on('input', function (msg) {
         var device = config.gateway;
         if (device.trim().length == 0) {
            device = globalContext.get("os").hostname();
         }
         device = device.toLowerCase();
         var address = config.address;
         if (address.trim().length == 0) {
            address = msg.topic;
         }
         address = address.toLowerCase();
         var porttype = config.porttype.toLowerCase();
	 var topic = 'rpdlite/' + device + '/' + config.msgtype + '/' + porttype + '/' + address;
         var payload = {
            device: device,
            type: porttype,
            address: address,
            value: msg.payload
            };
         msg.topic = topic;
         msg.payload = payload;
         node.send(msg)
      });
   }
   RED.nodes.registerType("build-msg", buildMsgNode);
}

