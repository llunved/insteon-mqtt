#===========================================================================
#
# Modem modify all link database handler.
#
#===========================================================================
import logging
from .. import message as Msg
from .Base import Base

LOG = logging.getLogger(__name__)


class ModemModifyDb(Base):
    """PLM Modem database modify message handler.

    This handles replies when we need to add, remove, or modify the
    all link database on the PLM modem.  An output OutAllLinkUpdate
    message is sent and the modem will ACK or NAK a reply back to
    indicate the result.

    The reply is passed to the modem.handle_db_update so it knows
    whether to store the updated result or not.
    """
    def __init__(self, modem):
        """Constructor

        Args
          modem:   (Modem) The Insteon modem.
        """
        super().__init__()

        self.modem = modem

    #-----------------------------------------------------------------------
    def msg_received(self, protocol, msg):
        """See if we can handle the message.

        See if the message is the expected ACK of our output.  If we
        get a reply, pass it to the modem to update it's database with
        the info.

        Args:
          protocol:  (Protocol) The Insteon Protocol object
          msg:       Insteon message object that was read.

        Returns:
          Msg.UNKNOWN if we can't handle this message.
          Msg.CONTINUE if we handled the message and expect more.
          Msg.FINISHED if we handled the message and are done.

        """
        if not isinstance(msg, Msg.OutAllLinkUpdate):
            return Msg.UNKNOWN

        # Message is an ACK/NAK of the record request.
        if msg.is_ack:
            LOG.info("Modem db updated: %s", msg)
            self.modem.db.handle_db_update(msg)
            self.modem.save_db()
        else:
            LOG.error("Modem db update error: %s", msg)

        return Msg.FINISHED

    #-----------------------------------------------------------------------