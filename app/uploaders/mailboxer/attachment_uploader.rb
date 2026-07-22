# Attachments are not supported in this fork.
#
# Upstream mailboxer mounts a CarrierWave uploader on
# Mailboxer::Message#attachment, and declares carrierwave (>= 0.5.8) as a
# runtime dependency.
#
# Every published carrierwave 3.x release constrains image_processing to
# (~> 1.1). Because upstream's carrierwave constraint has no upper bound,
# bundler resolves that conflict by walking carrierwave *backwards* -- to
# 1.3.2, which drops the image_processing dependency altogether -- rather than
# reporting it. The result is a silent two-major-version downgrade of an upload
# library, triggered by bumping an unrelated gem.
#
# The host application needs image_processing 2.x for newer image formats
# (AVIF among them) and never uses mailboxer attachments: no call site passes
# the optional `attachment` argument, nothing reads Message#attachment, and no
# row in the messages table has one set. So the dependency is removed here
# rather than pinning image_processing back to 1.x across the whole
# application.
#
# This class is kept rather than deleted so that any surviving reference still
# resolves and lands on this explanation. Instantiating it is a bug: it means
# something is trying to attach a file after all.
class Mailboxer::AttachmentUploader
  def initialize(*)
    raise Mailboxer::AttachmentsUnsupportedError,
          'Mailboxer attachments are not supported in this fork: carrierwave ' \
          'has been removed so the application can use image_processing 2.x. ' \
          'To restore attachments, re-add the carrierwave runtime dependency ' \
          'and the mount_uploader call in Mailboxer::Message.'
  end
end
