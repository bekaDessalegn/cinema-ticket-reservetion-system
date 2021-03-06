const _ = require("lodash");
const { ObjectId } = require("mongodb");
const { addDocument, getDocuments, updateDocument, deleteDocument, getDocument, checkExistence, groupInDates } = require("../commons/functions");
const { requireParamsNotSet, collectionNames, invalidId, defaultPrice, defaultCapacity, scheduleOverlap, oneDay } = require("../commons/variables");

class Schedule {
    id;
    movieId;
    startTime;
    movie;
    endTime;
    capacity;
    seatsLeft;
    price;

    constructor({
        id,
        movieId,
        movie,
        startTime,
        endTime,
        capacity,
        seatsLeft,
        price
    }) {
        this.id = id;
        this.movieId = movieId;
        this.movie = movie;
        this.startTime = startTime;
        this.endTime = endTime;
        this.capacity = _.isUndefined(capacity) ? defaultCapacity : capacity;
        this.seatsLeft = _.isUndefined(seatsLeft) ? this.capacity : seatsLeft;
        this.price = _.isUndefined(price) ? defaultPrice : price;
    }

    async save() {
        if (_.isUndefined(this.movieId) ||
            _.isUndefined(this.startTime) ||
            _.isUndefined(this.endTime)
        ) {
            throw new Error(requireParamsNotSet);
        } else {
            try {
                let scheduleOverlaps = await checkExistence(collectionNames.schedules,
                    {
                        "$or": [
                            { startTime: { "$lte": this.startTime }, endTime: { "$gt": this.startTime } },
                            { endTime: { "$gte": this.endTime }, startTime: { "$lt": this.endTime } }
                        ]
                    }
                );
                if (scheduleOverlaps) {
                    throw new Error(scheduleOverlap);
                } else {
                    let Movie = require("./movie");
                    this.movie = await Movie.find(this.movieId);
                    this.id = await addDocument(collectionNames.schedules, this);
                    await updateDocument(collectionNames.schedules, {_id:new ObjectId(this.id)}, this);
                    // @ts-ignore
                    delete this._id;
                    return this;
                }
            } catch (error) {
                throw error;
            }
        }
    }

    static async find(id) {
        if (_.isUndefined(id)) {
            throw new Error(requireParamsNotSet);
        } else {
            let _id;
            try {
                _id = new ObjectId(id);
            } catch (error) {
                throw new Error(invalidId);
            }
            try {
                let schedule = await getDocument(collectionNames.schedules, { _id });
                // @ts-ignore
                if (schedule) {
                    // @ts-ignore
                    schedule.id = schedule._id + "";
                    // @ts-ignore
                    delete schedule._id;
                    return new Schedule(schedule);
                } else {
                    return null;
                }
            } catch (error) {
                throw error;
            }
        }
    }
    static async findAll() {
        try {
            let schedules = await getDocuments(collectionNames.schedules);
            let allSchedules = [];
            let now = Date.now();
            let today = now - (now % oneDay)
            for (let schedule of schedules) {
                if (schedule.startTime < today) continue;
                delete schedule._id;
                // @ts-ignore
                allSchedules.push(new Schedule(schedule));
            }
            // @ts-ignore
            return groupInDates(allSchedules, ["startTime"]);
        } catch (error) {
            throw error;
        }
    }
    static async update({ id, updates }) {
        if (_.isUndefined(id) || _.isEmpty(updates)) {
            throw new Error(requireParamsNotSet);
        } else {
            let _id;
            try {
                _id = new ObjectId(id);
            } catch (error) {
                throw new Error(invalidId);
            }
            delete updates._id;
            try {
                let result = await updateDocument(collectionNames.schedules, { _id }, updates);
                return result.modifiedCount;
            } catch (error) {
                throw error;
            }
        }
    }

    static async delete({ id }) {
        if (_.isUndefined(id)) {
            throw new Error(requireParamsNotSet);
        } else {
            let _id;
            try {
                _id = new ObjectId(id);
            } catch (error) {
                throw new Error(invalidId);
            }
            try {
                let result = await deleteDocument(collectionNames.schedules, { _id });
                return result.deletedCount;
            } catch (error) {
                throw error;
            }
        }
    }
}

module.exports = Schedule;
