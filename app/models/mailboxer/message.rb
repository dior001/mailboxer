class Mailboxer::Message < Mailboxer::Notification
  attr_accessible :attachment if Mailboxer.protected_attributes?
  self.table_name = :mailboxer_notifications

  belongs_to :conversation, :validate => true, :autosave => true
  validates_presence_of :sender

  class_attribute :on_deliver_callback
  protected :on_deliver_callback
  scope :conversation, lambda { |conversation|
    where(:conversation_id => conversation.id)
  }

  # Upstream mounts a CarrierWave uploader here. This fork removes carrierwave
  # (see app/uploaders/mailboxer/attachment_uploader.rb), leaving `attachment`
  # as the plain :string column it is backed by.
  #
  # The messaging API still accepts an `attachment` argument and passes it
  # through as nil, which is why assigning nil stays valid. Assigning anything
  # else would previously have been handled by the uploader and would now be
  # type-cast to a string and silently stored as junk, so reject it loudly.
  def attachment=(value)
    if value.present?
      raise Mailboxer::AttachmentsUnsupportedError,
            'Mailboxer attachments are not supported in this fork: carrierwave ' \
            'has been removed so the application can use image_processing 2.x.'
    end

    write_attribute(:attachment, value)
  end

  class << self
    #Sets the on deliver callback method.
    def on_deliver(callback_method)
      self.on_deliver_callback = callback_method
    end
  end

  #Delivers a Message. USE NOT RECOMENDED.
  #Use Mailboxer::Models::Message.send_message instead.
  def deliver(reply = false, should_clean = true)
    self.clean if should_clean

    #Receiver receipts
    receiver_receipts = recipients.map do |r|
      receipts.build(receiver: r, mailbox_type: 'inbox', is_read: false)
    end

    #Sender receipt
    sender_receipt =
      receipts.build(receiver: sender, mailbox_type: 'sentbox', is_read: true)

    if valid?
      save!
      Mailboxer::MailDispatcher.new(self, receiver_receipts).call

      conversation.touch if reply

      self.recipients = nil

      on_deliver_callback.call(self) if on_deliver_callback
    end
    sender_receipt
  end
end
