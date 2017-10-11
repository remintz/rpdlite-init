module.exports = function (RED) {

   function buildMsgNode(config) {
      RED.nodes.createNode(this, config);
      var node = this;
      var context = this.context();
      var globalContext = this.context().global;

      this.on('input', function (msg) {
	 var topic = 'rpdlite/' + config.gateway + '/' + config.msgtype + '/' + config.porttype + '/' + config.address;
         var payload = {
            device: config.gateway,
            type: config.porttype,
            address: config.address,
            value: msg.payload
            };
         msg.topic = topic;
         msg.payload = payload;
         node.send(msg)
      });
   }
   RED.nodes.registerType("build-msg", buildMsgNode);
}

