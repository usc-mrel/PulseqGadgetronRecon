 
import numpy as np
import gadgetron
import ismrmrd
from ismrmrd.acquisition import Acquisition

def FixHeaders(connection):
    # connection.filter(lambda acq: acq.is_flag_set(ismrmrd.ACQ_IS_REVERSE))
    for acquisition in connection:
    #     acquisition_reverse = Acquisition(head=acquisition.getHead(), data=np.flip(acquisition.data, axis=1), trajectory=acquisition.traj)
        dshape = list(acquisition.bits[0].data.data.shape)
        dshape[2] = 1
        acquisition.bits[0].data.data = acquisition.bits[0].data.data[:,:,-1,:,:,:,:]
        acquisition.bits[0].data.data = np.reshape(acquisition.bits[0].data.data, dshape)
        acquisition.bits[0].data.sampling.encoded_matrix[2] = 1
        acquisition.bits[0].data.sampling.recon_matrix = acquisition.bits[0].data.sampling.encoded_matrix
        acquisition.bits[0].data.sampling.sampling_limits[2].max = 0
        acquisition.bits[0].data.sampling.sampling_limits[2].min = 0
        acquisition.bits[0].data.sampling.sampling_limits[2].center = 0

        hshape = list(acquisition.bits[0].data.headers.shape)
        hshape[1] = 1
        acquisition.bits[0].data.headers = acquisition.bits[0].data.headers[:,-1,:,:,:]
        acquisition.bits[0].data.headers = np.reshape(acquisition.bits[0].data.headers, hshape)
        print(f"N={acquisition.bits[0].data.data.shape[4]}, header={acquisition.bits[0].data.headers.shape[2]}")
        connection.header.encoding[0].encodedSpace.matrixSize.z = 1
        connection.send(acquisition)
        print('Sending acq...')

def Passthrough(connection):
    for acquisition in connection:
        connection.send(acquisition)


if __name__ == '__main__':
    gadgetron.external.listen(port=18000, handler=FixHeaders)
    # gadgetron.external.listen(port=18000, handler=Passthrough)