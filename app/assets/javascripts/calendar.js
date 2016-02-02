function initCalendar() {
  var events = $.map(JSON.parse($('#listing_availabilities_json').val()), function(e) {
    var start;
    if(e.date)
      start = moment(e.date)
    else
      start = moment();

    start.minute(e.start_at_minute);
    start.hour(e.start_at_hour);
    start.second(0);

    var end;
    if(e.date)
      end = moment(e.date)
    else
      end = moment();

    end.minute(e.end_at_minute);
    end.hour(e.end_at_hour);
    end.second(0);

    return { recurring: e.recurring, start: start, end: end };
  });

  var cal = $('#calendar').fullCalendar({
    header: {
      left: 'prev,next',
      center: 'title',
      right: 'month,agendaWeek'
    },
    contentHeight: "auto",
    defaultView: 'agendaWeek',
    minTime: '09:00:00',
    maxTime: '22:00:00',
    allDaySlot: false,
    editable: false,
    slotEventOverlap: false,
    eventDurationEditable: false,
    events: (events || []),
    eventRender: writeJSON,
    eventDrop: writeJSON,
    eventClick: function(calEvent, jsEvent, view) {
      if(view.type == "month") return false;

      if(calEvent.recurring) {
        var dialog = $('#remove_availability_dialog').lightbox_me({
          centered: true,
          zIndex: 1000000,
          onClose: function() {
            $('#add-recurring').unbind("click");
            $('#add-once').unbind("click");
            return false;
          }
        });

        $('#remove-recurring').click(function() {
          $('#remove-recurring').unbind("click");
          $('#remove-once').unbind("click");
          removeRecurringEvent(calEvent);
          writeJSON();
          dialog.trigger('close');
          return false;
        });

        $('#remove-once').click(function() {
          $('#remove-recurring').unbind("click");
          $('#remove-once').unbind("click");
          removeSingleEvent(calEvent);
          writeJSON();
          dialog.trigger('close');
          return false;
        });
      } else {
        removeSingleEvent(calEvent);
        writeJSON();
      }

      return false;
    },
    dayClick: function(startDate, jsEvent, view) {
      if(view.type == "month") return false;

      var dialog = $('#add_availability_dialog').lightbox_me({
        centered: true,
        zIndex: 1000000,
        onClose: function() {
          $('#add-recurring').unbind("click");
          $('#add-once').unbind("click");
          return false;
        }
      });

      if(!startDate.hasTime())
        startDate.hour(13);

      $('#add-recurring').click(function() {
        addRecurringEvent(startDate);
        dialog.trigger('close');
        return false;
      });

      $('#add-once').click(function() {
        addSingleEvent(startDate);
        dialog.trigger('close');

        var warningDialog = $('#add_once_warning_dialog').lightbox_me({ centered: true, zIndex: 1000000 });
        $('#add_once_warning_dialog button').click(function() {
          warningDialog.trigger('close');
          return false;
        });

        return false;
      });

      return false;
    }
  });

  function writeJSON() {
    var indexedEvents = {};
    var events = $.map($('#calendar').fullCalendar('clientEvents'), function(e, i) {
      return {
        start_at_hour: e.start.hour(),
        start_at_minute: e.start.minute(),
        end_at_hour: e.end.hour(),
        end_at_minute: e.end.minute(),
        date: e.start.format("DD/MM/YYYY"),
        recurring: e.recurring
      };
    });

    $('#listing_availabilities_json').val(JSON.stringify(events));
  };

  function addSingleEvent(start) {
    var end = start.clone();
    end.add(1.5, 'hour');

    calEvent = {
      start: start,
      end: end
    };

    $('#calendar').fullCalendar( 'renderEvent', calEvent, true);
  }

  function addRecurringEvent(start) {
    var numberOfEvents = 52 * 2 + 5; // 2 years & 5 weeks in the past
    var newStart = start
      .clone()
      .isoWeek(moment().isoWeek())
      .subtract(5, 'week');

    var events = [];

    for(i=0; i < numberOfEvents; i++) {
      calEvent = {
        start: newStart,
        end: newStart.clone().add(1.5, 'hour'),
        recurring: true
      };

      events.push(calEvent);

      newStart = newStart.clone();
      newStart.add(1, 'week');
    }
    $('#calendar').fullCalendar( 'addEventSource', { events: events });
  }

  function removeSingleEvent(calEvent) {
    $('#calendar').fullCalendar('removeEvents', calEvent._id);
  }

  function removeRecurringEvent(calEvent) {
    $('#calendar').fullCalendar('removeEvents', function(toBeDeletedCalEvent) {
      return equalMoments(toBeDeletedCalEvent.start, calEvent.start);
    });
  }

  function equalMoments(moment, otherMoment) {
    return moment.day() == otherMoment.day() &&
            moment.hour() == otherMoment.hour() &&
            moment.minute() == otherMoment.minute();
  }
}
